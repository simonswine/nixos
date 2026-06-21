{ config, pkgs, ... }:

{
  imports = [
    ../generic/kubernetes.nix
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = true;
  networking.hostId = "deadcafe";
  cloud.provider = "hcloud";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "20.09";
}
