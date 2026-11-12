{ config, lib, pkgs, ... }:

{
  imports = [
    ../generic/kubernetes.nix
  ];

  boot.supportedFilesystems = [ "btrfs" ];
  virtualisation.containerd-kubelet.snapshotter = "btrfs";
  # Also used by the image builder when it pre-pulls Kubernetes images.
  environment.etc."containerd/config.toml".source = config.virtualisation.containerd.args.config;
  services.prometheus-node-exporter-zfs.enable = lib.mkForce false;
  # Pin 6.12, as there is ebpf regression from 6.13
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  networking.hostId = "deadcafe";
  cloud.provider = "hcloud";
  services.cloud-init.btrfs.enable = true;

  virtualisation.containerd-kubelet.gvisor.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "20.09";
}
