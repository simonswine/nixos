{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.virtualisation.containerd-kubelet;
in
{
  options.virtualisation.containerd-kubelet = {
    enable = mkEnableOption "containerd as kubelet container runtime";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cri-tools ];
    environment.etc."crictl.yaml".text = ''
      runtime-endpoint: unix:///run/containerd/containerd.sock
    '';

    # disable cgroup v2, not ready yet for primetime (e.g. kubectl top nodes broken)
    boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=0" ];

    virtualisation.containerd = {
      enable = true;
      configFile = pkgs.writeText "config.toml" ''
        version = 2
        oom_score = -999

        [metrics]
          address = "127.0.0.1:1338"

        [plugins."io.containerd.grpc.v1.cri".containerd]
          default_runtime_name = "runc"
          snapshotter = "zfs"

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
          SystemdCgroup = true
      '';
    };

    ## TODO: environment.etc."cni/net.d/10-containerd-bridge.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/10-containerd-bridge.conf";
    ## TODO: environment.etc."cni/net.d/99-loopback.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/99-loopback.conf";

    systemd.services.containerd = {
      path = [ pkgs.zfs pkgs.iptables-nftables-compat ];
    };
  };
}
