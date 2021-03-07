{ config, pkgs, ... }:

{
  imports =
    [
      ../modules/containerd.nix
      ../modules/kubernetes-kubelet-kubeadm.nix
    ];

  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "deadcafe";

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
      - Hetzner
      - None
  '';

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0" ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.hostName = "";

  # This seems to be the stabler choice
  networking.usePredictableInterfaceNames = false;

  # Necessary for overlay network
  networking.wireguard.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    nixpkgs-fmt
    htop
    atop
    lsof
    tcpdump
    bwm_ng
  ];

  nixpkgs.overlays = [
    (import ../overlays/cloud-init/default.nix)
    (import ../overlays/kubernetes/default.nix)
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "20.09";

}
