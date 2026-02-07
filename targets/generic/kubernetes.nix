{ pkgs, ... }:

{
  # Necessary for overlay network
  networking.wireguard.enable = true;

  virtualisation.containerd-kubelet.enable = true;
  services.kubernetes.kubelet-kubeadm.enable = true;
  services.kubernetes.package = pkgs.kubernetes-1-34;
  services.prometheus-node-exporter-zfs = {
    enable = true;
    extraArgs = [
      "--exclude-snapshot-name"
      "^rpool/containerd/"
    ];
  };

  # Install nix flakes to allow modifications
  programs.nixflakes.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    nixfmt-tree
    nixfmt
    htop
    atop
    lsof
    tcpdump
    bwm_ng
  ];
}
