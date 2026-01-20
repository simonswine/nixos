{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.heatmiser-exporter;
in
with lib;

{
  options.services.heatmiser-exporter = {
    enable = mkEnableOption "heatmiser-exporter";

    listenAddress = mkOption {
      default = "127.0.0.1:4243";
      type = types.str;
    };

    neohubAddress = mkOption {
      default = "127.0.0.1:4242";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.heatmiser-exporter = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.heatmiser-exporter}/bin/heatmiser-exporter --listen-address ${cfg.listenAddress} --neohub-address ${cfg.neohubAddress}";
      };
    };
  };
}
