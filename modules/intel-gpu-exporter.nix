{ config, pkgs, lib, ... }:
let
  cfg = config.services.intel-gpu-exporter;
in
with lib;

{
  options.services.intel-gpu-exporter = {
    enable = mkEnableOption "intel-gpu-exporter";

    listenAddress = mkOption {
      default = "127.0.0.1:8282";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.intel-gpu-exporter = {
      wantedBy = [ "multi-user.target" ];
      description = "Export Intel's GPU stats as Prometheus metrics.";
      path = [ pkgs.intel-gpu-tools ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.intel-gpu-exporter}/bin/intel-gpu-exporter -listen-address ${cfg.listenAddress}";
      };
    };
  };
}
