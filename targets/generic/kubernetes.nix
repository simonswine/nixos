{ config, pkgs, ... }:

{
  # Necessary for overlay network
  networking.wireguard.enable = true;

  virtualisation.containerd.enable = true;
  services.kubernetes.kubelet-kubeadm.enable = true;
  services.kubernetes.package = pkgs.kubernetes-1-18;

  environment.systemPackages = with pkgs; [
    wget
    vim
    nixpkgs-fmt
    htop
    atop
    lsof
    tcpdump
    bwm_ng

    containerd
    kubernetes
  ];
}
