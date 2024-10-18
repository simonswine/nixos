{ lib
, config
, ...
}:
let
  rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
in
{

  boot = {
    kernelParams = [
      "root=UUID=${rootPartitionUUID}"
      "rootfstype=ext4"
    ];

    loader = {
      grub.enable = lib.mkForce false;
      generic-extlinux-compatible.enable = lib.mkForce true;
    };

    initrd.availableKernelModules = lib.mkForce [
      # NVMe
      "nvme"

      # SD cards and internal eMMC drives.
      "mmc_block"

      # Support USB keyboards, in case the boot fails and we only have
      # a USB keyboard, or for LUKS passphrase prompt.
      "hid"

      # For LUKS encrypted root partition.
      # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/system/boot/luksroot.nix#L985
      "dm_mod" # for LVM & LUKS
      "dm_crypt" # for LUKS
      "input_leds"
    ];
  };

  sdImage = {
    inherit rootPartitionUUID;
    compressImage = true;

    # install firmware into a separate partition: /boot/firmware
    populateFirmwareCommands = ''
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./firmware
    '';
    # Gap in front of the /boot/firmware partition, in mebibytes (1024×1024 bytes).
    # Can be increased to make more space for boards requiring to dd u-boot SPL before actual partitions.
    firmwarePartitionOffset = 32;
    firmwarePartitionName = "BOOT";
    firmwareSize = 200; # MiB

    populateRootCommands = ''
      mkdir -p ./files/boot
    '';
  };
}
