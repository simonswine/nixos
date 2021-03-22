{ config, pkgs, ... }:

{
  # Necessary for overlay network
  networking.wireguard.enable = true;

  virtualisation.containerd.enable = true;
  services.kubernetes.kubelet-kubeadm.enable = true;
  services.kubernetes.package = pkgs.kubernetes-1-18;

  # Install nix flakes to allow modifications
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

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
