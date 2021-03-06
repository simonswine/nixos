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
  environment.etc."cloud/cloud.cfg.d/90_hcloud.cfg".text = ''
    datasource_list: [ Hetzner, None ]
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
