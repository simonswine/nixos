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

      lock = pkgs.writeScript "swaylock" ''
        #!${pkgs.bash}/bin/bash

        set -euo pipefail
        set +x

        echo "hello-world" >> /tmp/my-log

        exec ${pkgs.swaylock-effects}/bin/swaylock \
                --debug \
                --clock \
                --image ${cfg.background} \
                --indicator \
                --indicator-thickness 7 \
                --indicator-radius 150 \
                --effect-vignette 0.4:0.4 \
                --font 'monospace' \
                --datestr '%a, %Y-%m-%d' "$@"
      '';

      screenshot_destination = "${config.home.homeDirectory}/Images/screenshots/scrn-$(date +\"%Y-%m-%d-%H-%M-%S\").png";
    in
    mkIf cfg.enable {

      gtk.theme.name = cfg.gtk_theme_name;

      home.packages = with pkgs; [
        xwayland # for legacy apps
        xorg.xeyes # for testing if app is wayland or xorg
        waybar # status bar
        mako # notification daemon
        wl-clipboard
        clipman # clipboard manager
        slurp # screen select
        wf-recorder # screen record
        grim # screenshot tool
        wofi # wofi
        dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
        xdg-desktop-portal-wlr
        xdg-desktop-portal
        pipewire
        libsForQt5.qt5ct
        wdisplays # this allows to configure the display
        wayvnc # remote desktop
      ];

      wayland.windowManager.sway = {
        enable = true;
        systemd.enable = false;
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

          # This enables wayland for slack and others chromium based applications
          export NIXOS_OZONE_WL=1

          # Firefox wayland support
          export MOZ_ENABLE_WAYLAND=1

          # this fixes nautilus' ability to browse network folders
          export GIO_EXTRA_MODULES="${pkgs.gnome.gvfs}/lib/gio/modules:$GIO_EXTRA_MODULES"

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

            terminal = "${pkgs.xfce.xfce4-terminal}/bin/xfce4-terminal";

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

            startup =
              let
                envVars = (builtins.concatStringsSep " " [ "DISPLAY" "WAYLAND_DISPLAY" "SWAYSOCK" "XDG_CURRENT_DESKTOP" ]);
              in
              [
                {
                  command = "${pkgs.writeScript "import-environment" ''
                    #!${pkgs.bash}/bin/bash

                    set -euo pipefail

                    dbus-update-activation-environment --systemd ${envVars}
                    ${pkgs.systemd}/bin/systemctl --user import-environment ${envVars}
                    ${pkgs.systemd}/bin/systemctl --user start sway-session.target
                  ''}";
                }
              ];

            workspaceAutoBackAndForth = true;

            keybindings = lib.mkOptionDefault {
              # use wofi as main menu
              "${modifier}+d" = "exec ${pkgs.wofi}/bin/wofi --insensitive --allow-images --show drun --define drun-print_command=true | sed 's/%.//' | xargs swaymsg exec --";

              # implement window switcher based on wofi
              "${modifier}+Tab" = "exec ${config.xdg.configHome}/sway/window-jump.sh";

              # power menu
              "${modifier}+Escape" = "exec ${config.xdg.configHome}/sway/wofi-power.sh";

              # wifi menu
              "${modifier}+End" = "exec ~/.dotfiles/rofi/modi/nmcli";

              # screenshots
              "${modifier}+Print" = "exec ${pkgs.grim}/bin/grim ${screenshot_destination}";
              "${modifier}+Shift+Print" = "exec ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - ${screenshot_destination}";

              # clipboard history
              "${modifier}+c" = "exec ${pkgs.clipman}/bin/clipman pick --tool wofi";

              # move whole workspace to other output
              "${modifier}+Control+h" = "move workspace to output left";
              "${modifier}+Control+j" = "move workspace to output down";
              "${modifier}+Control+k" = "move workspace to output up";
              "${modifier}+Control+l" = "move workspace to output right";

              # audio controls
              "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
              "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
              "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
              "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";

              # brightness controls
              "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
              "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
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

      systemd.user.targets.sway-session = {
        Unit = {
          Description = "sway compositor session";
          Documentation = [ "man:systemd.special(7)" ];
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };

      xdg.configFile."wofi/style.css" = {
        text = ''
          /*
           * wofi style. Colors are from authors below.
           * Base16 Gruvbox dark, medium
           * Author: Dawid Kurek (dawikur@gmail.com), morhetz (https://github.com/morhetz/gruvbox)
           *
           */
          @define-color base00 #282828;
          @define-color base01 #3C3836;
          @define-color base02 #504945;
          @define-color base03 #665C54;
          @define-color base04 #BDAE93;
          @define-color base06 #D5C4A1;
          @define-color base06 #EBDBB2;
          @define-color base07 #FBF1C7;
          @define-color base08 #FB4934;
          @define-color base09 #FE8019;
          @define-color base0A #FABD2F;
          @define-color base0B #B8BB26;
          @define-color base0C #8EC07C;
          @define-color base0D #83A598;
          @define-color base0E #D3869B;
          @define-color base0F #D65D0E;

          window {
            opacity: 0.9;
            border:  0px;
            border-radius: 10px;
            font-family: monospace;
            font-size: 18px;
          }

          #input {
            border-radius: 10px 10px 0px 0px;
            border:  0px;
            padding: 10px;
            margin: 0px;
            font-size: 28px;
            color: #222222;
            background-color: #ab6f60;
          }

          #inner-box {
            margin: 0px;
            color: @base06;
            background-color: @base00;
          }

          #outer-box {
            margin: 0px;
            background-color: @base00;
            border-radius: 10px;
          }

          #selected {
            background-color: #ab6f60;
          }

          #entry {
            padding: 0px;
            margin: 0px;
            background-color: @base00;
          }

          #scroll {
            margin: 5px;
            background-color: @base00;
          }

          #text {
            margin: 0px;
            padding: 2px 2px 2px 10px;
          }

        '';
      };

      xdg.configFile."sway/wofi-power.sh" = {
        executable = true;
        text = ''
          #!${pkgs.bash}/bin/bash

          set -euo pipefail

          entries="Lock\nLogout\nSuspend\nReboot\nShutdown"

          selected=$(echo -e $entries | ${pkgs.wofi}/bin/wofi --show dmenu --prompt "power" --insensitive | ${pkgs.gawk}/bin/awk '{print tolower($1)}')

          case $selected in
            lock)
              exec ${lock};;
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

          # Select window with wofi
          selected=$(echo "$windows" | ${pkgs.wofi}/bin/wofi -p "window" --show dmenu --insensitive | ${pkgs.gawk}/bin/awk '{print $1}')

          # Tell sway to focus said window
          ${pkgs.sway}/bin/swaymsg [con_id="$selected"] focus
        '';
      };
      systemd.user.services.swayidle = {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          Restart = "always";
          Environment = [
            "PATH=${lib.makeBinPath [ pkgs.sway ]}:/run/current-system/sw/bin/"
          ];
          ExecStart = [
            ''
              ${pkgs.unstable.swayidle}/bin/swayidle -w -d \
                timeout 1200 'swaymsg exec -- "${lock} -f"' \
                timeout 2700 'swaymsg "output * dpms off"' \
                resume 'swaymsg "output * dpms on"' \
                before-sleep 'swaymsg exec -- "${lock} -f"'
            ''
          ];
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };
    };
}

