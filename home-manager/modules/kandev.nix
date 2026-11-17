{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.kandev;
  path = lib.concatStringsSep ":" [
    "/home/christian/bin"
    "/run/wrappers/bin"
    "/home/christian/.nix-profile/bin"
    "/nix/profile/bin"
    "/home/christian/.local/state/nix/profile/bin"
    "/etc/profiles/per-user/christian/bin"
    "/nix/var/nix/profiles/default/bin"
    "/run/current-system/sw/bin"
  ];
in
{
  imports = [
    (mkRemovedOptionModule [ "simonswine" "kandev" "webPort" ]
      "Kandev now serves the frontend on backendPort; the separate Next.js service has been removed.")
  ];

  options.simonswine.kandev = {
    enable = mkEnableOption "kandev AI development task orchestrator";

    backendPort = mkOption {
      type = types.port;
      default = 38429;
      description = "Port for the kandev backend and web frontend";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      kandev = {
        Unit = {
          Description = "kandev Go backend";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${pkgs.bash}/bin/bash -c '. $HOME/.shell.grafana.secrets; exec ${pkgs.kandev}/bin/kandev __backend -port ${toString cfg.backendPort}'";
          Environment = [
            "KANDEV_WEB_DIST_DIR=${pkgs.kandev-frontend}"
            "PATH=${path}"
            "GIT_CONFIG_GLOBAL=/home/christian/.config/git/config-kandev"
          ];
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
