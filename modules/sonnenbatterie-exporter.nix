{ config, pkgs, lib, ... }:
let
  cfg = config.services.sonnenbatterie-exporter;
in
with lib;

{
  options.services.sonnenbatterie-exporter = {
    enable = mkEnableOption "sonnenbatterie-exporter";

    listenAddress = mkOption {
      default = "127.0.0.1:9110";
      type = types.str;
    };

    sonnenbatterieUrl = mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable {
    systemd.services.sonnenbatterie-exporter = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        EnvironmentFile = "-/etc/sysconfig/sonnenbatterie-exporter";
        ExecStart = "${pkgs.sonnenbatterie-exporter}/bin/sonnenbatterie-exporter -listen-address ${cfg.listenAddress} -sonnenbatterie-url ${cfg.sonnenbatterieUrl}";
      };
    };
  };
}
