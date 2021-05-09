{ config, pkgs, lib, ... }:
let
  cfg = config.services.flowercare-exporter;
in
with lib;

{
  options.services.flowercare-exporter = {
    enable = mkEnableOption "flowercare-exporter";

    listenAddress = mkOption {
      default = "127.0.0.1:9294";
    };

    sensors = mkOption {
      type = with types; attrsOf (str);
      default = { };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.flowercare-exporter = {
      wantedBy = [ "multi-user.target" ];
      description = "A prometheus exporter which can read data from Xiaomi MiFlora / HHCC Flower Care devices using Bluetooth.";
      serviceConfig = {
        Type = "simple";
        ExecStart =
          let
            sensorsList = mapAttrsToList (name: value: "--sensor ${name}=${value}") cfg.sensors;
            sensors = concatStringsSep " " sensorsList;
          in
          "${pkgs.flowercare-exporter}/bin/flowercare-exporter --addr ${cfg.listenAddress} ${sensors}";
      };
    };
  };
}
