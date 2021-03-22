{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "deadcafe";
  services.openssh.enable = true;

  kexec.autoReboot = false;

  services.cloud-init.enable = true;
  environment.etc."cloud/cloud.cfg.d/90_hcloud.cfg".text = ''
    datasource_list: [ Hetzner, None ]
  '';

  nixpkgs.overlays = [
    (import ../overlays/cloud-init/default.nix)
  ];

  system.stateVersion = "20.09";
}
