{ config, pkgs, lib, ... }:
let
  cfg = config.services.cert-updater;
in
with lib;

{
  options.services.cert-updater = {
    enable = mkEnableOption "cert-updater";

    apiserverUrl = mkOption {
      description = "Kubernetes apiserver URL.";
      type = types.str;
    };
    caCertFile = mkOption {
      description = "Kubernetes apiserver CA file.";
      type = types.path;
    };
    tokenFile = mkOption {
      description = "Kubernetes apiserver token file.";
      type = types.path;
    };

    namespace = mkOption {
      description = "Namespace of the secret.";
      type = types.str;
    };
    name = mkOption {
      description = "Name of the secret.";
      type = types.str;
    };

    certFile = mkOption {
      description = "Certificate destination path from secret.";
      type = types.path;
    };
    keyFile = mkOption {
      description = "Key destination path from secret.";
      type = types.path;
    };

    postUpdateHook = mkOption {
      description = "Script or command that gets executed after a successful change of certificate or key.";
      type = types.nullOr types.path;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cert-updater = {
      description = "Update certificate from kubernetes";
      serviceConfig = {
        ExecStart = "${pkgs.cert-updater}/bin/cert-updater --apiserver-url ${cfg.apiserverUrl} --namespace ${cfg.namespace} ${cfg.name} --key-file ${cfg.keyFile} --cert-file ${cfg.certFile} --token-file ${cfg.tokenFile} --ca-cert-file ${cfg.caCertFile} --post-update-hook ${cfg.postUpdateHook}";
      };
    };
    #systemd.timers.cert-updater = {
    #  timerConfig = {
    #    OnBootSec = "1 min";
    #    OnUnitActiveSec = "1 min";
    #  };
    #  wantedBy = [ "timers.target" ];
    #};
  };
}
