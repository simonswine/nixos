{
  lib,
  pkgs,
  config,
  ...
}:

# Extra configuration for the nixos-images based kexec installer used to
# bootstrap Hetzner Cloud nodes from the rescue system (see packer/scripts/
# boot-kexec.sh). The nixos-images kexec-installer/noninteractive modules
# already provide SSH access, host-key/authorized-key preservation and
# network restoration, so we only add what the subsequent nixos-install of
# the ZFS-on-root system needs.
{
  # The target system installs onto a ZFS root pool, so the installer
  # environment needs the ZFS kernel module and userspace tools available
  # for `install-nixos.sh` (zpool/zfs/mount -t zfs).
  #
  # Note: we deliberately do NOT use `boot.supportedFilesystems = [ "zfs" ]`
  # here: the kexec installer has no root pool to import at boot, and enabling
  # the full ZFS boot machinery on top of the netboot image causes a
  # conflicting `zfs-import.service` definition.
  boot.kernelModules = [ "zfs" ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}
  ];
  networking.hostId = "deadcafe";

  # Tooling required by packer/scripts/install-nixos.sh inside the installer:
  # ZFS userspace, git (to clone the flake repo) and cachix (binary cache).
  environment.systemPackages = [
    config.boot.zfs.package
    pkgs.git
    pkgs.cachix
  ];

  # `nixos-install --flake` needs flake support enabled in the installer.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Used by the standalone nixosConfigurations.hcloud-kexec; in the actual
  # kexec installer package the nixos-images installer module overrides this.
  system.stateVersion = lib.mkDefault "23.11";
}
