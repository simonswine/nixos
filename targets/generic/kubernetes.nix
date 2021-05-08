{ config, pkgs, ... }:

{
  # Necessary for overlay network
  networking.wireguard.enable = true;

  virtualisation.containerd.enable = true;
  services.kubernetes.kubelet-kubeadm.enable = true;
  services.kubernetes.package = pkgs.kubernetes-1-19;
  services.prometheus-node-exporter-zfs = {
    enable = true;
    extraArgs = [
      "--snapshots-ignore"
      "^rpool/containerd/"
    ];
  };

  # Install nix flakes to allow modifications
  programs.nixflakes.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    nixpkgs-fmt
    htop
    atop
    lsof
    tcpdump
    bwm_ng
  ];
}
