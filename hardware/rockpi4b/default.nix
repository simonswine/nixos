{
  lib,
  pkgs,
  ...
}:
{
  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = false;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "rootwait"

    "earlycon" # enable early console, so we can see the boot messages via serial port / HDMI
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "arm-trusted-firmware-rk3399"
    ];

  hardware = {
    deviceTree = {
      enable = true;
      name = "rockchip/rk3399-rock-pi-4b.dtb";
      filter = "**rk3399-rock-pi-4b.dtb";
    };
  };

  hardware.enableRedistributableFirmware = true;

}
