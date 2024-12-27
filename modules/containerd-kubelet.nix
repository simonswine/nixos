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
          "io.containerd.grpc.v1.cri" = {
            containerd = {
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
            cni.bin_dir = "/opt/cni/bin";
            sandbox_image = "registry.k8s.io/pause:3.9";
          };
        };
      };
    };
    ## TODO: environment.etc."cni/net.d/10-containerd-bridge.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/10-containerd-bridge.conf";
    ## TODO: environment.etc."cni/net.d/99-loopback.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/99-loopback.conf";

    systemd.services.containerd = {
      path = [ pkgs.zfs pkgs.iptables-nftables-compat ];
      serviceConfig = {
        # This limit was reduce from infinty to 1024:524288 as part of nixos 24.11. Raising that limit slightly.
        LimitNOFILE = "32768:524288";
      };
    };
  };
}
