{ config, pkgs, lib, ... }:
let
  cfg = config.services.prometheus-node-exporter-restic;
  cfgTextfiles = config.services.prometheus-node-exporter-textfiles;
in
with lib;

{
  options.services.prometheus-node-exporter-restic = {
    enable = mkEnableOption "prometheus-node-exporter-restic";
  };

  config = mkIf cfg.enable {
    services.prometheus-node-exporter-textfiles.enable = true;
    systemd.services.prometheus-node-exporter-restic = {
      description = "Node exporter textfile restic";
      serviceConfig = {
        ExecStart = "${pkgs.prometheus-node-exporter-restic}/bin/node-exporter-restic | ${pkgs.moreutils}/bin/sponge ${cfgTextfiles.path}/restic.prom'";
      };
    };
    systemd.timers.prometheus-node-exporter-restic = {
      timerConfig = {
        OnBootSec = "1 min";
        OnUnitActiveSec = "1 min";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
