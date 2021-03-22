{ config, pkgs, ... }:

{
  services.cloud-init.enable = true;
  services.cloud-init.config = ''
    system_info:
      distro: nixos
    users:
      - root
    disable_root: false
    preserve_hostname: false
    cloud_init_modules:
      - migrator
      - seed_random
      - bootcmd
      - write-files
      - growpart
      - resizefs
      - ca-certs
      - rsyslog
      - users-groups
    cloud_config_modules:
      - disk_setup
      - mounts
      - ssh-import-id
      - set-passwords
      - timezone
      - disable-ec2-metadata
      - runcmd
      - ssh
    cloud_final_modules:
      - rightscale_userdata
      - scripts-vendor
      - scripts-per-once
      - scripts-per-boot
      - scripts-per-instance
      - scripts-user
      - ssh-authkey-fingerprints
      - keys-to-console
      - phone-home
      - final-message
      - power-state-change
    datasource_list:
      - Scaleway
      - None
  '';

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiInstallAsRemovable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.hostName = "";

  # This seems to be the stabler choice
  networking.usePredictableInterfaceNames = false;
}
