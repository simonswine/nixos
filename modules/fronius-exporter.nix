{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.fronius-exporter;
in
with lib;

{
  options.services.fronius-exporter = {
    enable = mkEnableOption "fronius-exporter";

    listenAddress = mkOption {
      default = "127.0.0.1:9109";
      type = types.str;
    };

    froniusUrl = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable {
    systemd.services.fronius-exporter = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        EnvironmentFile = "-/etc/sysconfig/fronius-exporter";
        ExecStart = "${pkgs.fronius-exporter}/bin/fronius-exporter -listen-address ${cfg.listenAddress} -fronius-url ${cfg.froniusUrl}";
      };
    };
  };
}
