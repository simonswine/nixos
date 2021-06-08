{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.sway;
in
{
  options = {
    simonswine.sway = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      background = mkOption {
        type = types.str;
        default = pkgs.nixos-artwork.wallpapers.simple-red.gnomeFilePath;
      };

      gtk_theme_name = mkOption {
        type = types.str;
        default = "Mint-Y-Dark-Red";
      };
    };
  };

  config =
    let
      # xfocus window outputs the current active windows on sway for Xwayland
      x_focused_screen =
        let
          name = "get-focused-x-screen";
        in
        "$(${pkgs.symlinkJoin {
      name = name;
      paths = [ pkgs.get-focused-x-screen ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${name} \
          --set PATH ${lib.makeBinPath [ pkgs.sway pkgs.xorg.xrandr ]}
      '';
    }}/bin/${name})";

      lock = "${pkgs.swaylock-effects}/bin/swaylock --debug --clock --image ${cfg.background} --indicator --indicator-thickness 7 --indicator-radius 150 --effect-vignette 0.4:0.4 --font 'monospace' --datestr '%a, %Y-%m-%d'";

      screenshot_destination = "${config.home.homeDirectory}/Images/screenshots/scrn-$(date +\"%Y-%m-%d-%H-%M-%S\").png";
    in
    mkIf cfg.enable {

      gtk.theme.name = cfg.gtk_theme_name;

      home.packages = with pkgs; [
        swaylock-effects # lockscreen
        swayidle
        xwayland # for legacy apps
        xorg.xeyes # for testing if app is wayland or xorg
        waybar # status bar
        mako # notification daemon
        kanshi # autorandr
        wl-clipboard
        clipman # clipboard manager
        slurp # screen select
        wf-recorder # screen record
        grim # screenshot tool
        rofi # rofi
        dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
        xdg-desktop-portal-wlr
        xdg-desktop-portal
        pipewire
        qt5ct
      ];

      wayland.windowManager.sway = {
        enable = true;
        systemdIntegration = true;
        wrapperFeatures = { gtk = true; };

        extraSessionCommands = ''
          export SDL_VIDEODRIVER=wayland
          # needs qt5.qtwayland in systemPackages
          export QT_QPA_PLATFORM=wayland
          export QT_QPA_PLATFORMTHEME=qt5ct
          export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          # Fix for some Java AWT applications (e.g. Android Studio),
          # use this if they aren't displayed properly:
          export _JAVA_AWT_WM_NONREPARENTING=1

          # Some bug
          export WLR_DRM_NO_MODIFIERS=1

          # Firefox wayland support
          export MOZ_ENABLE_WAYLAND=1

          # Use legacy intel driver (better support in browsers)
          export LIBVA_DRIVER_NAME=i965

          # this fixes nautilus' ability to browse network folders
          export GIO_EXTRA_MODULES="${pkgs.gnome3.gvfs}/lib/gio/modules:$GIO_EXTRA_MODULES"

          # expose GTK theme to most things 
          # TODO: Figure out why that makes firefox unreadable
          # export GTK_THEME=${cfg.gtk_theme_name}

          export XDG_CURRENT_DESKTOP=sway
        '';

        config =
          let
            modifier = "Mod4";
          in
          {
            modifier = modifier;

            terminal = "${pkgs.alacritty}/bin/alacritty";


            gaps = {
              inner = 10;
              smartGaps = true;
              smartBorders = "on";
            };

            window = {
              border = 1;
              hideEdgeBorders = "smart";
            };

            floating = {
              titlebar = true;
            };

            fonts = {
              names = [ "FontAwesome 10" "Terminus 10" ];
            };

            # disable bars, as we have waybar
            bars = [ ];

            startup = [
              # restart kanshi after reload
              { command = "systemctl --user restart kanshi"; always = true; }
            ];

            workspaceAutoBackAndForth = true;

            keybindings = lib.mkOptionDefault {
              # use rofi as main menu
              "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -m ${x_focused_screen} -show drun -run-command '${pkgs.sway}/bin/swaymsg exec -- {cmd}'";

              # implement window switcher based on rofi
              "${modifier}+Tab" = "exec ${config.xdg.configHome}/sway/window-jump.sh";

              # power menu
              "${modifier}+Escape" = "exec ${config.xdg.configHome}/sway/rofi-power.sh";

              # wifi menu
              "${modifier}+End" = "exec ~/.dotfiles/rofi/modi/nmcli";

              # screenshots
              "${modifier}+Print" = "exec ${pkgs.grim}/bin/grim ${screenshot_destination}";
              "${modifier}+Shift+Print" = "exec ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - ${screenshot_destination}";

              # clipboard history
              "${modifier}+c" = "exec ${pkgs.clipman}/bin/clipman pick -t rofi -T\"-m ${x_focused_screen}\"";

              # move whole workspace to other output
              "${modifier}+Control+h" = "move workspace to output left";
              "${modifier}+Control+j" = "move workspace to output down";
              "${modifier}+Control+k" = "move workspace to output up";
              "${modifier}+Control+l" = "move workspace to output right";
            };

            input = {
              "*" = {
                xkb_layout = "us";
                xkb_variant = ",,";
                xkb_options = "compose:ralt";
              };
            };

            output = {
              "*" = {
                bg = "${cfg.background} fill";
              };
            };

          };
      };

      xdg.configFile."sway/lock.sh" = {
        executable = true;
        text = ''
          #!${pkgs.stdenv.shell}

          exec ${lock}
        '';
      };

      xdg.configFile."sway/rofi-power.sh" = {
        executable = true;
        text = ''
          #!${pkgs.stdenv.shell}

          set -euo pipefail

          entries="Lock,Logout,Suspend,Reboot,Shutdown"

          selected=$(echo $entries | ${pkgs.rofi}/bin/rofi -m ${x_focused_screen} -dmenu -sep ',' -p "power" -i | ${pkgs.gawk}/bin/awk '{print tolower($1)}')

          case $selected in
            lock)
              exec ${config.xdg.configHome}/sway/lock.sh;;
            logout)
              ${pkgs.sway}/bin/swaymsg exit;;
            suspend)
              exec systemctl suspend;;
            reboot)
              exec systemctl reboot;;
            shutdown)
              exec systemctl poweroff -i;;
          esac
        '';
      };

      xdg.configFile."rofi/config.rasi" = {
        text = ''
          configuration {
              modi:            "drun,window";
              show-icons:      true;
              icon-theme:      "Paper";
              sidebar-mode:    false;
              display-drun:    "";
          }

          * {
              color-background: rgba(35, 31, 32, 0.85);
              color-text:       rgba(217, 216, 216, 1);
              color-highlight:  rgba(0, 157, 220, 1);

              background-color: transparent;
              text-color:       @color-text;
              spacing:          30;

              font:             "Sans 18";
          }

          #window {
              fullscreen:       true;
              transparency:     "background";

              background-color: @color-background;

              children:         [ dummy1, hdum, dummy2 ];
          }

          #hdum {
              orientation: horizontal;
              children:    [ dummy3, mainbox, dummy4 ];
          }

          #element selected {
              text-color: @color-highlight;
          }
        '';
      };

      xdg.configFile."sway/window-jump.sh" = {
        executable = true;
        text = ''
          #!${pkgs.stdenv.shell}

          set -euo pipefail

          # Get available windows
          windows=$(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq -r '.. | objects | select(.type=="con" and .name != null)| "\(.id)\t\(.name)"')

          # Select window with rofi
          selected=$(echo "$windows" | ${pkgs.rofi}/bin/rofi -m ${x_focused_screen} -p "window" -dmenu -i | ${pkgs.gawk}/bin/awk '{print $1}')

          # Tell sway to focus said window
          ${pkgs.sway}/bin/swaymsg [con_id="$selected"] focus
        '';
      };
      systemd.user.services.swayidle = {
        Unit = {
          Description = "swayidle ";
          PartOf = [ "graphical-session.target" ];
        };

        Service =
          let
            lock-escaped = (builtins.replaceStrings [ "%" ] [ "%%" ] lock);
          in
          {
            ExecStart = [
              ''
                ${pkgs.swayidle}/bin/swayidle -w -d \
                  timeout 1200 "exec ${lock-escaped} -f" \
                  timeout 2700 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
                  resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
                  before-sleep "exec ${lock-escaped} -f"
              ''
            ];
          };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };
    };
}
