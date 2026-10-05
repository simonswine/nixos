{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.roc-vad;
  driver = "${cfg.package}/Library/Audio/Plug-Ins/HAL/roc_vad.driver";
  cli = "${cfg.package}/bin/roc-vad";
  deviceCommands = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      key: device:
      let
        uid = lib.escapeShellArg device.uid;
        stateKey = builtins.hashString "sha256" device.uid;
        configHash = builtins.hashString "sha256" (builtins.toJSON device);
        endpoints = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            slot: ep:
            "${cli} device ${
              if device.type == "sender" then "connect" else "bind"
            } --uid ${uid} --slot ${lib.escapeShellArg slot} "
            + lib.concatStringsSep " " (
              lib.mapAttrsToList (
                kind: uri:
                "--${
                  {
                    audiosrc = "source";
                    audiorpr = "repair";
                    audioctl = "control";
                  }
                  .${kind}
                } ${lib.escapeShellArg uri}"
              ) (lib.filterAttrs (_: uri: uri != null) ep)
            )
          ) device.remoteEndpoints
        );
      in
      ''
        deviceMarker="$stateDir/${stateKey}"
        exists=false
        if ${cli} device show --uid ${uid} >/dev/null 2>&1; then
          exists=true
        fi
        if [ "$exists" != true ] || [ ! -f "$deviceMarker" ] || \
           [ "$(/bin/cat "$deviceMarker")" != ${lib.escapeShellArg configHash} ]; then
          echo ${lib.escapeShellArg "Applying Roc VAD device: ${device.name}"}
          # Invalidate before making changes so a failed application is retried.
          /bin/rm -f "$deviceMarker"
          if [ "$exists" = true ]; then
            ${cli} device del --uid ${uid}
          fi
          ${cli} device add ${device.type} --uid ${uid} --name ${lib.escapeShellArg device.name}
          ${endpoints}
          # Record success only after every endpoint has been configured.
          printf '%s\n' ${lib.escapeShellArg configHash} > "$deviceMarker.tmp"
          /bin/mv "$deviceMarker.tmp" "$deviceMarker"
        fi
      ''
    ) cfg.devices
  );
in
{
  options.services.roc-vad = {
    enable = lib.mkEnableOption "Roc virtual audio device for macOS";
    devices = lib.mkOption {
      default = { };
      description = ''
        Declarative devices, recreated only when their configuration changes or
        they are missing. Other devices are untouched. The last successfully
        applied configuration is tracked locally; manual changes are not detected.
        Removing an entry does not delete its persisted device; delete it manually
        with roc-vad device del --uid UID.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }: {
            options = {
              type = lib.mkOption {
                type = lib.types.enum [
                  "sender"
                  "receiver"
                ];
                default = "sender";
              };
              name = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Display name in macOS audio settings.";
              };
              uid = lib.mkOption {
                type = lib.types.str;
                default = "nix-roc-vad-${name}";
                description = "Stable device UID. Must be unique; an existing device with this UID is replaced.";
              };
              remoteEndpoints = lib.mkOption {
                default = { };
                description = "Endpoint slots, keyed by numeric slot ID. Senders connect; receivers bind.";
                type = lib.types.attrsOf (
                  lib.types.submodule {
                    options = lib.genAttrs [ "audiosrc" "audiorpr" "audioctl" ] (
                      _:
                      lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                        description = "Endpoint URI, or null to omit.";
                      }
                    );
                  }
                );
              };
            };
          }
        )
      );
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../pkgs/roc-vad { };
      description = "Roc VAD package containing the CLI and CoreAudio driver bundle.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    assertions = [
      {
        assertion =
          let
            uids = map (device: device.uid) (lib.attrValues cfg.devices);
          in
          builtins.length uids == builtins.length (lib.unique uids);
        message = "services.roc-vad.devices must have unique UIDs.";
      }
      {
        assertion = lib.all (
          device: lib.all (slot: builtins.match "[0-9]+" slot != null) (lib.attrNames device.remoteEndpoints)
        ) (lib.attrValues cfg.devices);
        message = "services.roc-vad device endpoint slots must be non-negative integers.";
      }
    ];

    # CoreAudio requires a real bundle in the system HAL directory.
    # Do not modify/sign the upstream bundle or link it into the Nix store.
    system.activationScripts.postActivation.text = ''
      (
        set -eu
        hal=/Library/Audio/Plug-Ins/HAL
        target="$hal/roc_vad.driver"
        marker="$hal/.roc-vad-nix-package"
        if [ ! -d "$target" ] || [ ! -f "$marker" ] || \
           [ "$(/bin/cat "$marker")" != ${lib.escapeShellArg driver} ]; then
          echo "Installing Roc VAD CoreAudio driver..."
          /bin/mkdir -p "$hal"
          staging=$(/usr/bin/mktemp -d "$hal/.roc-vad.XXXXXX")
          trap '/bin/rm -rf "$staging"' EXIT
          /bin/cp -R ${lib.escapeShellArg driver} "$staging/roc_vad.driver"
          /usr/sbin/chown -R root:wheel "$staging/roc_vad.driver"
          /bin/chmod -R go-w "$staging/roc_vad.driver"
          /bin/rm -rf "$target"
          /bin/mv "$staging/roc_vad.driver" "$target"
          printf '%s\n' ${lib.escapeShellArg driver} > "$marker"
          /usr/bin/killall coreaudiod || true
        fi
        ${lib.optionalString (cfg.devices != { }) ''
          # CoreAudio loads the driver asynchronously after installation/restart.
          ready=false
          for _ in $(/usr/bin/seq 1 30); do
            if ${cli} info >/dev/null 2>&1; then
              ready=true
              break
            fi
            /bin/sleep 1
          done
          if [ "$ready" != true ]; then
            echo "Roc VAD driver did not become ready within 30 seconds" >&2
            exit 1
          fi
          stateDir='/Library/Application Support/roc-vad-nix'
          /bin/mkdir -p "$stateDir"
          /usr/sbin/chown root:wheel "$stateDir"
          /bin/chmod 700 "$stateDir"
          ${deviceCommands}
        ''}
      )
    '';
  };
}
