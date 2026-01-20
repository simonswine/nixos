{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.mtv-dl;
in
{
  meta.maintainers = [ maintainers.simonswine ];

  options.services.mtv-dl = {
    enable = mkEnableOption "mtv-dl";

    uid = mkOption {
      default = 18001;
      type = types.int;
    };

    gid = mkOption {
      default = 18001;
      type = types.int;
    };

    shows = mkOption {
      default = [ ];
      type = types.listOf types.str;
    };

    dataDir = mkOption {
      default = "/var/lib/mtv-dl";
      type = types.path;
      description = "The directory for storing the mtv-dl data.";
    };

    package = mkOption {
      default = pkgs.mtv-dl;
      defaultText = "pkgs.mtv-dl";
      type = types.package;
      description = "MediathekView Downloader package to use.";
    };

  };

  config = mkIf cfg.enable {
    systemd.services.mtv-dl =
      let
        showsFile = pkgs.writeText "shows.conf" (concatStringsSep "\n" cfg.shows);
      in
      {
        description = "MediathekView Downloader";
        after = [ "network.target" ];
        #wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStartPre = [
            "/run/current-system/sw/bin/cp -f ${showsFile} ${cfg.dataDir}/shows.conf"
            "/run/current-system/sw/bin/chmod 0600 ${cfg.dataDir}/shows.conf"
          ];
          ExecStart = concatStringsSep " " [
            "${cfg.package}/bin/mtv_dl"
            "list"
            "--quiet"
            "--no-bar"
            "--sets=${cfg.dataDir}/shows.conf"
            "--dir=${cfg.dataDir}"
          ];
          Environment = [
            "TIMEZONE=Europe/London"
          ];
          User = "mtv-dl";
          Group = "mtv-dl";

          # Security hardening
          ReadWritePaths = [ cfg.dataDir ];
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          PrivateDevices = true;
        };
      };

    users.users.mtv-dl = {
      group = "mtv-dl";
      home = cfg.dataDir;
      createHome = true;
      uid = cfg.uid;
      isNormalUser = false;
      isSystemUser = true;
    };

    users.groups.mtv-dl.gid = cfg.gid;
  };
}
