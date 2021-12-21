{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.restic;

  timerConfig = {
    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* 2:00:00";
    };

    randomizedDelay = mkOption {
      type = types.str;
      default = "30min";
    };
  };

  retentionConfig = {
    daily = mkOption {
      type = types.int;
      default = 21;
    };

    weekly = mkOption {
      type = types.int;
      default = 8;
    };

    monthly = mkOption {
      type = types.int;
      default = 12;
    };

    yearly = mkOption {
      type = types.int;
      default = 10;
    };

    last = mkOption {
      type = types.int;
      default = 5;
    };
  };

  targetConfig = {
    excludes = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    paths = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    backupTimer = mkOption {
      default = { };
      type = types.submodule { options = timerConfig; };
    };

    retention = mkOption {
      default = { };
      type = types.submodule { options = retentionConfig; };
    };
  };

  backupName = name: "restic-backup-${name}";
  forgetName = name: "restic-forget-${name}";

  commonService = name: {
    Type = "oneshot";
    CPUQuota = "10%";
    Nice = 19;
    IOSchedulingClass = "idle";
    CPUSchedulingPolicy = "idle";
    Environment = [
      "GOGC=20"
    ];
    # Limit memory
    MemoryMax = "6G";

    # Ensure we are the first to be killed my OOM
    OOMScoreAdjust = 1000;

    # Allow to provide password out-of-bound
    EnvironmentFile = "-%h/.config/restic/${name}/environment";
  };

in
{
  options.simonswine.restic = {
    enable = mkEnableOption "simonswine restic backup config";

    targets = mkOption {
      default = { };
      type = with types; attrsOf (submodule { options = targetConfig; });
      description = "Definition of restic backup targets.";
    };


  };

  config = {
    systemd.user = {
      services =
        mapAttrs'
          (name: config: nameValuePair (backupName name) (
            {
              Unit = {
                Description = "Restic backup ${name}";
              };
              Service = ((commonService name) // {
                ExecStart = [
                  "${pkgs.restic}/bin/restic backup --verbose --one-file-system --tag systemd.timer --exclude-file=${pkgs.writeText "restic-excludes" (builtins.concatStringsSep "\n" config.excludes)} ${builtins.concatStringsSep " " config.paths}"
                ];
              });
            }
          ))
          cfg.targets
        //
        mapAttrs'
          (name: config: nameValuePair (forgetName name) (
            {
              Unit = {
                Description = "Clean up restic backups ${name}";
              };
              Service = ((commonService name) // {
                ExecStart = [
                  (
                    "${pkgs.restic}/bin/restic forget --verbose --tag systemd.timer --group-by 'paths,tag' --prune " +
                    "--keep-daily ${toString config.retention.daily} " +
                    "--keep-weekly ${toString config.retention.weekly} " +
                    "--keep-monthly ${toString config.retention.monthly} " +
                    "--keep-yearly ${toString config.retention.yearly} " +
                    "--keep-last ${toString config.retention.last}"
                  )
                ];
              });
            }
          ))
          cfg.targets;

      timers =
        mapAttrs'
          (name: config: nameValuePair (backupName name) ({
            Unit = {
              Description = "Run restic backup for ${name}";
            };
            Timer = {
              OnCalendar = config.backupTimer.onCalendar;
              RandomizedDelaySec = config.backupTimer.randomizedDelay;
              Persistent = "true";
            };
            Install = {
              WantedBy = [ "timers.target" ];
            };
          }))
          cfg.targets
        //
        mapAttrs'
          (name: config: nameValuePair (forgetName name) ({
            Unit = {
              Description = "Clean up restic backups ${name}";
            };
            Timer = {
              OnCalendar = "monthly";
              RandomizedDelaySec = "2h";
              Persistent = "true";
            };
            Install = {
              WantedBy = [ "timers.target" ];
            };
          }))
          cfg.targets;
    };
  };
}
