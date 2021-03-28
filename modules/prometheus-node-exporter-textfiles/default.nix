{ config, pkgs, lib, ... }:
let
  cfg = config.services.prometheus-node-exporter-textfiles;
  cfgNodeExporter = config.services.prometheus.exporters.node;

  python = pkgs.python3.withPackages (p: [
    p.prometheus_client
  ]);
in
with lib;

{
  options.services.prometheus-node-exporter-textfiles = {
    enable = mkEnableOption "prometheus-node-exporter-textfiles";

    path = mkOption {
      default = "/var/lib/prometheus-node-exporter-textfiles";
    };
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enabledCollectors = [
        "textfile"
      ];
      extraFlags = [
        "--collector.textfile.directory=${cfg.path}"
      ];
    };
    system.activationScripts.prometheus-node-exporter-textfiles =
      (if cfgNodeExporter.enable then ''
        # Ensure textfile directory exists
        mkdir -pm 2770 "${cfg.path}"

        # chown folder for node exporter
        chown ${cfgNodeExporter.user}:${cfgNodeExporter.group} "${cfg.path}"
      '' else ''
        # Ensure textfile directory exists
        mkdir -pm 0775 "${cfg.path}"
      '')
      +
      ''
        # Expose nixos version information
        ${python}/bin/python ${./nixos.py} --destination-path ${cfg.path}/nixos.prom
      '';
  };
}
