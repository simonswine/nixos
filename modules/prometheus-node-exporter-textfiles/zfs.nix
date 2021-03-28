{ config, pkgs, lib, ... }:
let
  cfg = config.services.prometheus-node-exporter-zfs;
  cfgTextfiles = config.services.prometheus-node-exporter-textfiles;

  args = [
    "--destination-path"
    "${cfgTextfiles.path}/zfs.prom"
  ] ++ cfg.extraArgs;
in
with lib;

{
  options.services.prometheus-node-exporter-zfs = {
    enable = mkEnableOption "prometheus-node-exporter-zfs";

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };


  config = mkIf cfg.enable {
    services.prometheus-node-exporter-textfiles.enable = true;
    systemd.services.prometheus-node-exporter-zfs = {
      description = "Node exporter script for zfs snapshots and pools";
      serviceConfig = {
        ExecStart = "${pkgs.prometheus-node-exporter-zfs}/bin/node-exporter-zfs ${lib.escapeShellArgs args}";
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
