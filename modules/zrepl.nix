{ config, pkgs, lib, ... }:
let
  cfg = config.services.zrepl;
in
with lib;

{
  options = {
    services.zrepl = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = ''
          Start zrepl daemon for automatic zfs replication.
        '';
      };

      config = mkOption {
        default = ''
          global:
            monitoring:
              - type: prometheus
                listen: '127.0.0.1:9111'
          jobs: []
        '';
        type = with types; uniq string;
        description = ''
          zrepl config
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    environment.etc."zrepl/zrepl.yml".text =
      cfg.config;


    systemd.services.zrepl = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Start zrepl daemon for automatic zfs replication.";
      path = [ pkgs.zfs pkgs.openssh ];
      serviceConfig = {
        Type = "simple";
        ExecStartPre = [
          ''${pkgs.coreutils}/bin/install -m0700 -d /var/run/zrepl''
          ''${pkgs.coreutils}/bin/install -m0700 -d /var/run/zrepl/stdinserver''
        ];

        ExecStart = ''${pkgs.zrepl}/bin/zrepl daemon --config /etc/zrepl/zrepl.yml'';
      };
      restartTriggers = [ config.environment.etc."zrepl/zrepl.yml".source ];
    };

    environment.systemPackages = [ pkgs.zrepl ];
  };
}
