{ config, pkgs, lib, ... }:
let
  cfg = config.services.growatt-proxy-exporter;
in
with lib;

{
  options.services.growatt-proxy-exporter = {
    enable = mkEnableOption "growatt-proxy-exporter";
  };

  config = mkIf cfg.enable {
    systemd.services.growatt-proxy-exporter = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        EnvironmentFile = "-/etc/sysconfig/growatt-proxy-exporter";
        ExecStart = "${pkgs.growatt-proxy-exporter}/bin/growatt-proxy-exporter";
      };
    };
  };
}
