{ config, pkgs, lib, ... }:
let
  cfg = config.services.kvmd-oled;
in
with lib;

{
  options.services.kvmd-oled = {
    enable = mkEnableOption "kvmd-oled";

    font = mkOption {
      description = "Font to use for OLED display.";
      type = types.path;
      default = "${pkgs.proggyfonts}/share/fonts/truetype/ProggySquare.ttf";
    };
    welcomeImage = mkOption {
      description = "Image to show at start up.";
      type = types.path;
      default = "${pkgs.kvmd-oled}/share/images/hello.ppm";
    };
  };

  config =
    let
      command = "${pkgs.kvmd-oled}/bin/kvmd-oled --font ${cfg.font} --height=32";
    in
    mkIf cfg.enable {
      systemd.services.kvmd-oled = {
        description = "Pi-KVM - Small OLED daemon";
        wantedBy = [ "multi-user.target" ];
        unitConfig = {
          After = "systemd-modules-load.service";
          ConditionPathExists = "/dev/i2c-1";
        };
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 3;
          TimeoutStopSec = 3;
          ExecStartPre = "${command} --clear-on-exit --interval=3 --image ${cfg.welcomeImage}";
          ExecStart = "${command} --clear-on-exit";
        };
      };
      systemd.services.kvmd-oled-reboot = {
        description = "Pi-KVM - Display reboot message on the OLED";
        wantedBy = [ "reboot.target" ];
        unitConfig = {
          After = "kvmd-oled.service";
          DefaultDependencies = "no";
          ConditionPathExists = "/dev/i2c-1";
        };
        serviceConfig = {
          Type = "simple";
          TimeoutStartSec = 0;
          ExecStart = ''${command} --offset-y=6 --interval=0 --text="Rebooting...\nPlease wait"'';
        };
      };
      systemd.services.kvmd-oled-shutdown = {
        description = "Pi-KVM - Display shutdown message on the OLED";
        wantedBy = [ "shutdown.target" ];
        unitConfig = {
          After = "kvmd-oled.service";
          Conflicts = "reboot.target";
          Before = [ "shutdown.target" "poweroff.target" "halt.target" ];
          DefaultDependencies = "no";
          ConditionPathExists = "/dev/i2c-1";
        };
        serviceConfig = {
          Type = "simple";
          TimeoutStartSec = 0;
          ExecStart = ''${command} --offset-y=12 --interval=0 --text="Halted"'';
        };
      };
    };
}
