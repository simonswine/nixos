{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.zrepl;

  filterAttrsRec = pred: v:
    if isAttrs v then
      filterAttrs pred (mapAttrs (path: filterAttrsRec pred) v)
    else
      v;

  serveConfig = {
    type = mkOption {
      type = types.enum [ "stdinserver" ];
    };

    client_identities = mkOption {
      type = with types; nullOr (listOf str);
      default = null;
    };
  };

  connectConfig = {
    type = mkOption {
      type = types.enum [ "ssh+stdinserver" ];
    };

    host = mkOption {
      type = types.str;
    };

    user = mkOption {
      type = types.str;
      default = "root";
    };

    identity_file = mkOption {
      type = types.str;
    };

    port = mkOption {
      default = 22;
    };
  };

  jobConfig = {
    type = mkOption {
      type = types.enum [ "snap" "source" "sink" "pull" "push" ];
    };

    filesystems = mkOption {
      default = null;
    };

    root_fs = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    interval = mkOption {
      default = null;
    };

    pruning = mkOption {
      default = null;
    };

    snapshotting = mkOption {
      default = null;
    };

    serve = mkOption {
      type = with types; nullOr (submodule [{ options = serveConfig; }]);
      default = null;
    };

    connect = mkOption {
      type = with types; nullOr (submodule [{ options = connectConfig; }]);
      default = null;
    };
  };

  toYAML = name: attrs: pkgs.runCommandNoCC name
    {
      preferLocalBuild = true;
      json = builtins.toFile "${name}.json" (builtins.toJSON attrs);
      nativeBuildInputs = [ pkgs.remarshal ];
    } ''json2yaml -i $json -o $out'';
in
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

      prometheusListenAddress = mkOption {
        default = "127.0.0.1:9111";
        description = "Prometheus metrics listen address";
      };

      prometheusEnable = mkOption {
        default = true;
        type = with types; bool;
        description = "Expose Prometheus metrics";
      };


      jobs = mkOption {
        default = { };
        type = with types; attrsOf (submodule [{ options = jobConfig; }]);
        description = " Definition  of zrepl tasks.";
      };
    };
  };

  config = mkIf cfg.enable {

    environment.etc."zrepl/zrepl.yml".source = toYAML "zrepl.yml" ({
      global = {

        monitoring =
          if cfg.prometheusEnable then
            ([
              {
                type = "prometheus";
                listen = cfg.prometheusListenAddress;
              }
            ]) else ([ ]);
      };

      jobs = mapAttrsToList
        (n: v:
          (filterAttrsRec
            (n: v: v != null)
            ({
              name = n;
            } // v)))
        cfg.jobs;

    });

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
