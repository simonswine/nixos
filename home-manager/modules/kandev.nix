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
  options.simonswine.kandev = {
    enable = mkEnableOption "kandev AI development task orchestrator";

    webPort = mkOption {
      type = types.port;
      default = 37429;
      description = "Port for the kandev Next.js frontend";
    };

    backendPort = mkOption {
      type = types.port;
      default = 38429;
      description = "Port for the kandev Go backend";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      kandev-web = {
        Unit = {
          Description = "kandev Next.js frontend";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${pkgs.nodejs}/bin/node ${pkgs.kandev-frontend}/web/server.js";
          Environment = [
            "HOSTNAME=127.0.0.1"
            "PORT=${toString cfg.webPort}"
          ];
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      kandev = {
        Unit = {
          Description = "kandev Go backend";
          After = [
            "network.target"
            "kandev-web.service"
          ];
          Requires = [ "kandev-web.service" ];
        };
        Service = {
          ExecStart = "${pkgs.bash}/bin/bash -c '. $HOME/.shell.grafana.secrets; exec ${pkgs.kandev}/bin/kandev -port ${toString cfg.backendPort}'";
          Environment = [
            "KANDEV_WEB_INTERNAL_URL=http://127.0.0.1:${toString cfg.webPort}"
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
