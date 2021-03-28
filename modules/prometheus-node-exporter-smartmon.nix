{ config, pkgs, lib, ... }:
let
  cfg = config.services.prometheus-node-exporter-smartmon;
  cfgTextfiles = config.services.prometheus-node-exporter-textfiles;
in
with lib;

{
  options.services.prometheus-node-exporter-smartmon = {
    enable = mkEnableOption "prometheus-node-exporter-smartmon";
  };

  config = mkIf cfg.enable {
    services.prometheus-node-exporter-textfiles.enable = true;
    systemd.services.prometheus-node-exporter-smartmon = {
      description = "Node exporter textfile smartmon";
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash -euo pipefail -c '${pkgs.prometheus-node-exporter-smartmon}/bin/node-exporter-smartmon | ${pkgs.moreutils}/bin/sponge ${cfgTextfiles.path}/smartmon.prom'";
      };
    };
    systemd.timers.prometheus-node-exporter-smartmon = {
      timerConfig = {
        OnBootSec = "1 min";
        OnUnitActiveSec = "1 min";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
