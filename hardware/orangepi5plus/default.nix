{ pkgs
, lib
, ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../pkgs/orangepi5-kernel { });

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
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

      # Allow network access
      "r8169"
    ];

    # kernelParams copy from Armbian's /boot/armbianEnv.txt & /boot/boot.cmd
    kernelParams = [
      "rootwait"

      "earlycon" # enable early console, so we can see the boot messages via serial port / HDMI
      "consoleblank=0" # disable console blanking(screen saver)
      "console=ttyS2,1500000" # serial port
      "console=tty1" # HDMI

      # docker optimizations
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "swapaccount=1"
    ];
  };

  # add some missing deviceTree in armbian/linux-rockchip:
  # orange pi 5 plus's deviceTree in armbian/linux-rockchip:
  #    https://github.com/armbian/linux-rockchip/blob/rk-5.10-rkr4/arch/arm64/boot/dts/rockchip/rk3588-orangepi-5-plus.dts
  hardware = {
    deviceTree = {
      enable = true;
      # https://github.com/armbian/build/blob/f9d7117/config/boards/orangepi5-plus.wip#L10C51-L10C51
      name = "rockchip/rk3588-orangepi-5-plus.dtb";
      filter = "**rk3588-orangepi-5-plus.dtb";
      overlays = [
      ];
    };

    firmware = [
      pkgs.orangepi-firmware
    ];
  };
}
