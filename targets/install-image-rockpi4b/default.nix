{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
let
  rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
in
{
  imports = [
    "${toString modulesPath}/installer/sd-card/sd-image.nix"
    ../../common/install-image-base.nix
    ../../hardware/rockpi4b/default.nix
  ];

  boot = {
    kernelParams = [
      "root=UUID=${rootPartitionUUID}"
      "rootfstype=ext4"
    ];

    # Force to use extlinux for sd image booting
    loader = {
      generic-extlinux-compatible.enable = lib.mkForce true;
      systemd-boot.enable = lib.mkForce false;
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
    imageBaseName = "nixos-sd-image-rockpi4b";
    firmwareSize = 512; # MiB
    populateFirmwareCommands = lib.mkForce ''
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./firmware
    '';
    populateRootCommands = lib.mkForce ''
      mkdir -p ./files/boot
    '';
  };

  system.build.sdImage = lib.mkForce (
    let
      rootfsImage = pkgs.callPackage "${toString modulesPath}/../lib/make-ext4-fs.nix" (
        {
          inherit (config.sdImage) storePaths;
          compressImage = true;
          populateImageCommands = config.sdImage.populateRootCommands;
          volumeLabel = "NIXOS_SD";
        }
        // lib.optionalAttrs (config.sdImage.rootPartitionUUID != null) {
          uuid = config.sdImage.rootPartitionUUID;
        }
      );
    in
    pkgs.callPackage (
      {
        stdenv,
        dosfstools,
        e2fsprogs,
        mtools,
        libfaketime,
        util-linux,
        zstd,
      }:
      stdenv.mkDerivation {
        name = config.sdImage.imageName;

        nativeBuildInputs = [
          dosfstools
          e2fsprogs
          mtools
          libfaketime
          util-linux
          zstd
        ];

        inherit (config.sdImage) compressImage;

        diskUUID = "A8ABB0FA-2FD7-4FB8-ABB0-2EEB7CD66AFA";
        loadUUID = "534078AF-3BB4-EC43-B6C7-828FB9A788C6";
        bootUUID = "95D89D52-CA00-42D6-883F-50F5720EF37E";
        espUUID = "2E5CB30A-A2F2-49A6-B21A-1138BCFF6EB5";
        rootUUID = "0340EA1D-C827-8048-B631-0C60D4478796";

        buildCommand = ''
          mkdir -p $out/nix-support $out/sd-image
          export img=$out/sd-image/${config.sdImage.imageName}

          echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
          if test -n "$compressImage"; then
            echo "file sd-image $img.zst" >> $out/nix-support/hydra-build-products
          else
            echo "file sd-image $img" >> $out/nix-support/hydra-build-products
          fi

          root_fs=${rootfsImage}
          ${lib.optionalString config.sdImage.compressImage ''
            root_fs=./root-fs.img
            echo "Decompressing rootfs image"
            zstd -d --no-progress "${rootfsImage}" -o $root_fs
          ''}

          # Create the image file sized to fit /boot/firmware and /, plus slack for the gap.
          rootSizeBlocks=$(du -B 512 --apparent-size $root_fs | awk '{ print $1 }')
          firmwareSizeBlocks=$((${toString config.sdImage.firmwareSize} * 1024 * 1024 / 512))
          imageSize=$((rootSizeBlocks * 512 + firmwareSizeBlocks * 512 + 20 * 1024 * 1024))
          truncate -s $imageSize $img

          sfdisk --no-reread --no-tell-kernel $img <<EOF
                label: gpt
                label-id: $diskUUID
                first-lba: 64
                start=64,                              size=8000,                            type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=$loadUUID, name=loader1
                start=16384,                           size=8192,                            type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=$bootUUID, name=loader2
                start=32768,                           size=$((firmwareSizeBlocks)), type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid=$espUUID,  name=bootfs, attrs=LegacyBIOSBootable
                start=$((32768 + firmwareSizeBlocks)),                                       type=B921B045-1DF0-41C3-AF44-4C6F280D3FAE, uuid=$rootUUID, name=rootfs
          EOF

          # Copy the rootfs into the SD image
          eval $(partx $img -o START,SECTORS --nr 4 --pairs)
          dd conv=notrunc if=./root-fs.img of=$img seek=$START count=$SECTORS

          # Create a FAT32 /boot/firmware partition of suitable size into firmware_part.img
          eval $(partx $img -o START,SECTORS --nr 3 --pairs)
          truncate -s $((SECTORS * 512)) firmware_part.img

          mkfs.vfat --invariant -i ${config.sdImage.firmwarePartitionID} -n ${config.sdImage.firmwarePartitionName} firmware_part.img

          # Populate the files intended for /boot/firmware
          mkdir firmware
          ${config.sdImage.populateFirmwareCommands}

          find firmware -exec touch --date=2000-01-01 {} +
          # Copy the populated /boot/firmware into the SD image
          cd firmware
          # Force a fixed order in mcopy for better determinism, and avoid file globbing
          for d in $(find . -type d -mindepth 1 | sort); do
            faketime "2000-01-01 00:00:00" mmd -i ../firmware_part.img "::/$d"
          done
          for f in $(find . -type f | sort); do
            mcopy -pvm -i ../firmware_part.img "$f" "::/$f"
          done
          cd ..

          # Verify the FAT partition before copying it.
          fsck.vfat -vn firmware_part.img
          dd conv=notrunc if=firmware_part.img of=$img seek=$START count=$SECTORS

          # Copy u-boot into the SD image
          eval $(partx $img -o START,SECTORS --nr 2 --pairs)
          dd conv=notrunc if=${pkgs.ubootRockPi4}/u-boot.itb of=$img seek=$START count=$SECTORS

          # Copy bootloader into the SD image
          eval $(partx $img -o START,SECTORS --nr 1 --pairs)
          dd conv=notrunc if=${pkgs.ubootRockPi4}/idbloader.img of=$img seek=$START count=$SECTORS

          ${config.sdImage.postBuildCommands}

          if test -n "$compressImage"; then
              zstd -T$NIX_BUILD_CORES --rm $img
          fi
        '';

        buildCommandX = ''
          mkdir -p $out/nix-support $out/sd-image
          export img=$out/sd-image/${config.sdImage.imageName}
          echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
          if test -n "$compressImage"; then
            echo "file sd-image $img.zstd" >> $out/nix-support/hydra-build-products
          else
            echo "file sd-image $img" >> $out/nix-support/hydra-build-products
          fi
          echo "Decompressing rootfs image"
          zstd -d --no-progress "${rootfsImage}" -o ./root-fs.img

          # Create the image file sized to fit /boot/firmware and /, plus slack for the gap.
          rootSizeBlocks=$(du -B 512 --apparent-size ./root-fs.img | awk '{ print $1 }')

          # rootfs will be at offset 0x8000, so we'll need to account for that.
          # And add an additional 600mb slack at the end.
          imageSize=$((0x8000 + rootSizeBlocks * 512 + 600 * 1024 * 1024))
          truncate -s $imageSize $img

          sfdisk --no-reread --no-tell-kernel $img <<EOF
              label: gpt
              label-id: $diskUUID
              first-lba: 64
              start=64,    size=8000, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=$loadUUID, name=loader1
              start=16384, size=8192, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=$bootUUID, name=loader2
              start=32768, size=8192, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=$espUUID, name=boot-esp, attrs=LegacyBIOSBootable
              start=32768,            type=B921B045-1DF0-41C3-AF44-4C6F280D3FAE, uuid=$rootUUID, name=root
          EOF

          if test -n "$compressImage"; then
              zstd -T$NIX_BUILD_CORES --rm $img
          fi
        '';
      }
    ) { }
  );
}
