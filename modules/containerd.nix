{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.virtualisation.containerd;
in
{
  imports = [
    (mkRenamedOptionModule [ "virtualisation" "containerd" "registries" ] [ "virtualisation" "containers" "registries" "search" ])
  ];

  meta = {
    maintainers = lib.teams.podman.members;
  };

  disabledModules = [ "virtualisation/containerd.nix" ];
  options.virtualisation.containerd = {
    enable = mkEnableOption "containerd container runtime";

    package = lib.mkOption {
      type = types.package;
      default = pkgs.containerd;
      internal = true;
      description = ''
        The final containerd package (including extra packages).
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package pkgs.cri-tools ];

    environment.etc."crictl.yaml".text = ''
      runtime-endpoint: unix:///run/containerd/containerd.sock
    '';

    environment.etc."containerd/config.toml".text = ''
      version = 2
      oom_score = -999

      [metrics]
        address = "127.0.0.1:1338"

      [plugins."io.containerd.grpc.v1.cri".containerd]
        snapshotter = "zfs"

      [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        runtime_type = "io.containerd.runtime.v1.linux"
        runtime_engine = "runc"

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
        SystemdCgroup = true
    '';

    # TODO: environment.etc."cni/net.d/10-containerd-bridge.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/10-containerd-bridge.conf";
    # TODO: environment.etc."cni/net.d/99-loopback.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/99-loopback.conf";

    # Enable common /etc/containers configuration
    virtualisation.containers.enable = true;

    systemd.services.containerd = {
      description = "containerd container runtime";
      documentation = [ "https://containerd.io" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "local-fs.target" ];
      path = [ cfg.package pkgs.zfs pkgs.runc pkgs.iptables pkgs.iptables-nftables-compat ];
      serviceConfig = {
        Type = "notify";
        ExecStart = "${cfg.package}/bin/containerd";
        Delegate = "yes";
        KillMode = "process";
        Restart = "always";
        LimitNPROC = "infinity";
        LimitCORE = "infinity";
        LimitNOFILE = "1048576";
        TasksMax = "infinity";
      };
    };
  };
}
