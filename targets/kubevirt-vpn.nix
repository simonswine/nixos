{ config, pkgs, lib, ... }:

{
  # Install nix flakes to allow modifications
  programs.nixflakes.enable = true;

modules = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  environment.systemPackages = with pkgs;
    [
      vim
      git
      cachix
      wireguard-tools
    ];

  services.prometheus.exporters.wireguard.enable = true;
  services.prometheus.exporters.openvpn.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "21.05";
}
