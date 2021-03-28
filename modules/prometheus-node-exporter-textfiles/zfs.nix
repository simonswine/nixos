{ config, pkgs, lib, ... }:
let
  cfg = config.services.prometheus-node-exporter-zfs;
  cfgTextfiles = config.services.prometheus-node-exporter-textfiles;
in
with lib;

{
  options.services.prometheus-node-exporter-zfs = {
    enable = mkEnableOption "prometheus-node-exporter-zfs";
  };

  config = mkIf cfg.enable {
    services.prometheus-node-exporter-textfiles.enable = true;
    systemd.services.prometheus-node-exporter-zfs = {
      description = "Node exporter script for zfs snapshots and pools";
      serviceConfig = {
        ExecStart = "${pkgs.prometheus-node-exporter-zfs}/bin/node-exporter-zfs --destination-path ${cfgTextfiles.path}/zfs.prom";
      };
    };
    systemd.timers.prometheus-node-exporter-zfs = {
      timerConfig = {
        OnBootSec = "1 min";
        OnUnitActiveSec = "1 min";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
