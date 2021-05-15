{ config, pkgs, lib, ... }:
let
  cfg = config.services.mi-flora-exporter;
in
with lib;

{
  options.services.mi-flora-exporter = {
    enable = mkEnableOption "mi-flora-exporter";

    listenAddress = mkOption {
      default = "127.0.0.1:9294";
    };

    sensors = mkOption {
      type = with types; attrsOf (str);
      default = { };
    };
  };

  config = mkIf cfg.enable {
    security.wrappers.mi-flora-exporter = {
      source = "${pkgs.mi-flora-exporter}/bin/mi-flora-exporter";
      capabilities = "cap_net_admin+eip";
    };

    systemd.services.mi-flora-exporter = {
      wantedBy = [ "multi-user.target" ];
      description = "A prometheus exporter which can read data from Xiaomi MiFlora / HHCC Flower Care devices using Bluetooth.";
      serviceConfig = {
        Type = "simple";
        ExecStart =
          let
            sensorsList = mapAttrsToList (name: value: "--sensor-name ${name}=${value}") cfg.sensors;
            sensors = concatStringsSep " " sensorsList;
          in
          "${pkgs.mi-flora-exporter}/bin/mi-flora-exporter exporter --bind-address ${cfg.listenAddress} ${sensors}";
      };
    };
  };
}
