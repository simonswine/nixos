{ config, pkgs, ... }:

{
  imports = [
    ../generic/kubernetes.nix
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = true;
  # Pin 6.12, as there is ebpf regression from 6.13
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  networking.hostId = "deadcafe";
  cloud.provider = "hcloud";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "20.09";
}
