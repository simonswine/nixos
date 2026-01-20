{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.waybar;

in
{
  options = {
    simonswine.waybar = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config =
    let
      configJsonnet = pkgs.writeText "waybar.jsonnet" ''
        local configVerbose = {
          layer: 'top',
          position: 'bottom',
          'modules-right': [
            'network',
          ],
          network: {
            format: '{ifname}',
            'format-wifi': '{essid} ({signalStrength}%) ',
            'format-ethernet': '{ifname} 🖧 ',
            'format-disconnected': ''',  //An empty format will hide the module.
            'tooltip-format': '{ifname}',
            'tooltip-format-wifi': |||
              interface  {ifname}
              ip    {ipaddr}/{cidr}
              up    {bandwidthUpOctets}
              down    {bandwidthDownOctets}
              signal    {signaldBm}
              frequency  {frequency}
              essid    {essid}
            |||,
            'tooltip-format-ethernet': |||
              interface  {ifname}
              ip    {ipaddr}/{cidr}
              up    {bandwidthUpOctets}
              down    {bandwidthDownOctets}
            |||,
            'tooltip-format-disconnected': 'Disconnected',
            'max-length': 50,
            interval: 2,
          },
          output: ['DP-6'],
        };

        local config = {
          layer: 'top',
          position: 'top',
          'modules-left': [
            'sway/workspaces',
            'custom/right-arrow-dark',
          ],
          'modules-center': [
            'custom/left-arrow-dark',
            'clock#1',
            'custom/left-arrow-light',
            'custom/left-arrow-dark',
            'clock#2',
            'custom/right-arrow-dark',
            'custom/right-arrow-light',
            'clock#3',
            'custom/right-arrow-dark',
          ],
          'modules-right': [
            'custom/left-arrow-dark',
            'temperature',
            'custom/left-arrow-light',
            'custom/left-arrow-dark',
            'pulseaudio',
            'custom/left-arrow-light',
            'custom/left-arrow-dark',
            'memory',
            'custom/left-arrow-light',
            'custom/left-arrow-dark',
            'cpu',
            'custom/left-arrow-light',
            'custom/left-arrow-dark',
            'battery',
            'custom/left-arrow-light',
            'custom/left-arrow-dark',
            'disk',
            'custom/left-arrow-light',
            'custom/left-arrow-dark',
            'tray',
          ],
          'custom/left-arrow-dark': {
            format: '',
            tooltip: false,
          },
          'custom/left-arrow-light': {
            format: '',
            tooltip: false,
          },
          'custom/right-arrow-dark': {
            format: '',
            tooltip: false,
          },
          'custom/right-arrow-light': {
            format: '',
            tooltip: false,
          },
          'sway/workspaces': {
            'disable-scroll': true,
            format: '{name}',
          },
          temperature: {
            interval: 1,
            format: ' {temperatureC}°C',
          },
          'clock#1': {
            interval: 1,
            format: '{:%a KW%V}',
            tooltip: false,
            'on-click': 'gnome-calendar',
          },
          'clock#2': {
            interval: 1,
            format: '{:%H:%M:%S}',
            tooltip: false,
            'on-click': 'gnome-calendar',
          },
          'clock#3': {
            interval: 1,
            format: '{:%Y-%m-%d}',
            tooltip: false,
            'on-click': 'gnome-calendar',
          },
          pulseaudio: {
            format: '{icon} {volume:2}%',
            'format-bluetooth': '{icon}  {volume}%',
            'format-muted': 'MUTE',
            'format-icons': {
              headphones: '♪',
              default: [
                '♪',
                '♪',
              ],
            },
            'scroll-step': 5,
            'on-click': 'pamixer -t',
            'on-click-right': 'pavucontrol',
          },
          memory: {
            interval: 1,
            format: ' {}%',
          },
          cpu: {
            interval: 1,
            format: ' {usage:2}%',
          },
          battery: {
            states: {
              warning: 20,
              critical: 10,
            },
            format: '{icon} {capacity}%',
            'format-charging': '{icon}+ {capacity}% ({time})',
            'format-plugged': '{icon}   {capacity}%',
            'format-discharging': '{icon}- {capacity}% ({time})',
            'format-icons': ['', '', '', '', ''],
          },
          disk: {
            interval: 5,
            format: ' {free:2}',
            path: '/',
          },
          tray: {
            'icon-size': 20,
          },
        };

        local outputs = std.extVar('outputs');

        local isLowWidth(output) =
          output.rect.width < 1600;

        local lowWidthOutputs = std.filter(isLowWidth, outputs);

        local normalOutputs = std.filter(function(o) !isLowWidth(o), outputs);

        // remove clock
        local lowWidthConfig = config {
          'modules-center':: [],
        };

        // no low width outputs
        if std.length(lowWidthOutputs) == 0 then config
        // only low width outputs
        else if std.length(normalOutputs) == 0 then lowWidthConfig
        // mixed case
        else
          [
            configVerbose,
            config {
              output: [
                o.name
                for o in normalOutputs
              ],
            },
            lowWidthConfig {
              output: [
                o.name
                for o in lowWidthOutputs
              ],
            },
          ]
      '';

      style = pkgs.writeText "waybar.css" ''
        * {
          font-size: 16px;
          font-family: monospace;
        }

        window#waybar {
          background: #292b2e;
          color: #fdf6e3;
        }

        #custom-right-arrow-dark,
        #custom-left-arrow-dark {
          color: #1a1a1a;
        }
        #custom-right-arrow-light,
        #custom-left-arrow-light {
          color: #292b2e;
          background: #1a1a1a;
        }

        #workspaces,
        #clock.1,
        #clock.2,
        #clock.3,
        #pulseaudio,
        #memory,
        #cpu,
        #battery,
        #disk,
        #temperature,
        #tray {
          background: #1a1a1a;
        }

        #workspaces button {
          padding: 0 2px;
          color: #fdf6e3;
        }
        #workspaces button.focused {
          color: #ea6b6b;
        }
        #workspaces button:hover {
          box-shadow: inherit;
          text-shadow: inherit;
        }
        #workspaces button:hover {
          background: #1a1a1a;
          border: #1a1a1a;
          padding: 0 3px;
        }

        #pulseaudio {
          color: #268bd2;
        }
        #memory {
          color: #2aa198;
        }
        #cpu {
          color: #6c71c4;
        }
        #battery {
          color: #859900;
        }
        #disk {
          color: #b58900;
        }

        #temperature {
          color: #ffe57c;
        }

        #clock,
        #pulseaudio,
        #memory,
        #temperature,
        #cpu,
        #battery,
        #disk {
          padding: 0 10px;
        }

      '';

      script = pkgs.writeScriptBin "waybar" ''
        #!${pkgs.stdenv.shell}

        set -x
        set -euo pipefail

        export PATH=$HOME/.nix-profile/bin:$HOME/bin:$PATH

        CONFIG_PATH=$(${pkgs.coreutils}/bin/mktemp /tmp/waybar-config.XXXXXX)

        # generate config, ensure that small width disable are using a reduced bar
        ${pkgs.jsonnet}/bin/jsonnet --ext-code "outputs=$(${pkgs.sway}/bin/swaymsg -t get_outputs)" "${configJsonnet}" > "''${CONFIG_PATH}"

        exec ${pkgs.waybar}/bin/waybar -l trace --config "''${CONFIG_PATH}" --style "${style}" "$@"
      '';
    in
    mkIf cfg.enable {
      systemd.user.services.waybar = {
        Unit = {
          Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
          Documentation = "https://github.com/Alexays/Waybar/wiki";
          PartOf = [ "graphical-session.target" ];
          Requisite = [ "dbus.service" ];
          After = [ "dbus.service" ];
        };

        Service = {
          Type = "dbus";
          BusName = "fr.arouillard.waybar";
          ExecStart = "${script}/bin/waybar";
          Restart = "always";
          RestartSec = "1sec";
        };

        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };
    };
}
