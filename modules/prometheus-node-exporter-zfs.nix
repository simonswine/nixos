{ config, pkgs, lib, ... }:
let
  cfg = config.services.prometheus-node-exporter-zfs;
  cfgTextfiles = config.services.prometheus-node-exporter-textfiles;

  args = [
    "--log-level"
    "debug"
    "--text-file-output"
    "${cfgTextfiles.path}/zfs.prom"
  ]
  ++ cfg.extraArgs
  ++ lib.lists.concatMap (x: [ "--exclude-snapshot-name" x ]) cfg.excludeSnapshotName
  ;
in
with lib;

{
  options.services.prometheus-node-exporter-zfs = {
    enable = mkEnableOption "prometheus-node-exporter-zfs";

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    excludeSnapshotName = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };


  config = mkIf cfg.enable {
    services.prometheus-node-exporter-textfiles.enable = true;
    systemd.services.prometheus-node-exporter-zfs = {
      description = "Node exporter textfile daemon for zfs snapshots and pools";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.prometheus-node-exporter-zfs}/bin/node-exporter-zfs ${lib.escapeShellArgs args}";
      };
    };
  };
}
