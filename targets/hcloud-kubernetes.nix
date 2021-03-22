{ config, pkgs, ... }:

{
  imports =
    [
      ./generic/kubernetes.nix
      ./generic/hcloud.nix
    ];

  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "deadcafe";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "20.09";
}
