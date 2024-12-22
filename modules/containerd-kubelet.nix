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

    virtualisation.containerd = {
      enable = true;
      settings = {
        version = 2;
        oom_score = -999;
        metrics = {
          address = "127.0.0.1:1338";
        };
        plugins = {
          "io.containerd.grpc.v1.cri".containerd = {
            default_runtime_name = "runc";
            snapshotter = "zfs";
            runtimes = {
              runc = {
                runtime_type = "io.containerd.runc.v2";
                options = {
                  SystemdCgroup = true;
                };
              };
            };
          };
        };
      };
    };

    ## TODO: environment.etc."cni/net.d/10-containerd-bridge.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/10-containerd-bridge.conf";
    ## TODO: environment.etc."cni/net.d/99-loopback.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/99-loopback.conf";

    systemd.services.containerd = {
      path = [ pkgs.zfs pkgs.iptables-nftables-compat ];
    };
  };
}
