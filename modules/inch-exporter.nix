{ config, pkgs, lib, ... }:
let
  cfg = config.services.inch-exporter;
in
with lib;

{
  options.services.inch-exporter = {
    enable = mkEnableOption "inch-exporter";

    listenAddress = mkOption {
      default = "127.0.0.1:9111";
      type = types.str;
    };

    inchUrl = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable {
    systemd.services.inch-exporter = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        EnvironmentFile = "-/etc/sysconfig/inch-exporter";
        ExecStart = "${pkgs.inch-exporter}/bin/inch-exporter -listen-address ${cfg.listenAddress} -inch-url ${cfg.inchUrl}";
      };
    };
  };
}
