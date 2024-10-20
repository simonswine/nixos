{ lib
, config
, modulesPath
, ...
}:
{
  imports = [
    "${toString modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ../../common/install-image-base.nix
  ];

  sdImage = {
    # Gap in front of the /boot/firmware partition, in mebibytes (1024×1024 bytes).
    # Can be increased to make more space for boards requiring to dd u-boot SPL before actual partitions.
    firmwarePartitionOffset = 32;
    firmwarePartitionName = "BOOT";
    firmwareSize = 512; # MiB
  };
}
