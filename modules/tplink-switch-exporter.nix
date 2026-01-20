{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.tplink-switch-exporter;
in
with lib;

{
  options.services.tplink-switch-exporter = {
    enable = mkEnableOption "tplink-switch-exporter";

    listenAddress = mkOption {
      default = "127.0.0.1:9108";
      type = types.str;
    };

    hostname = mkOption {
      type = types.str;
    };

    username = mkOption {
      default = "admin";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.tplink-switch-exporter = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        EnvironmentFile = "-/etc/sysconfig/tplink-switch-exporter";
        ExecStart = "${pkgs.tplink-switch-exporter}/bin/tplink-switch-exporter -listen-address ${cfg.listenAddress} -switch-hostname ${cfg.hostname} -switch-username ${cfg.username}";
      };
    };
  };
}
