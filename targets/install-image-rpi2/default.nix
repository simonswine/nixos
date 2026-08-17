{
  lib,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    "${toString modulesPath}/installer/sd-card/sd-image-raspberrypi.nix"
    ../../common/install-image-base.nix
  ];

  boot.zfs.forceImportRoot = true;

  # profiles/base.nix (pulled in by sd-image-raspberrypi.nix) unconditionally
  # adds efibootmgr and efivar to systemPackages, but efivar is marked broken
  # on 32-bit (NixOS/nixpkgs#388309), which makes this image fail to evaluate.
  # A Raspberry Pi 2 boots via u-boot/extlinux, so EFI tooling is dead weight.
  nixpkgs.overlays = [
    (final: prev: {
      efivar = final.emptyDirectory;
      efibootmgr = final.emptyDirectory;
    })
  ];

  sdImage = {
    # Gap in front of the /boot/firmware partition, in mebibytes (1024×1024 bytes).
    # Can be increased to make more space for boards requiring to dd u-boot SPL before actual partitions.
    firmwarePartitionOffset = 32;
    firmwarePartitionName = "BOOT";
    firmwareSize = 512; # MiB
  };
}
