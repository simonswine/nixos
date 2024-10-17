{ config, pkgs, ... }:

{
  imports =
    [
      ./generic/kubernetes.nix
    ];

  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "deadcafe";
  cloud.provider = "scaleway";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "20.09";
}
