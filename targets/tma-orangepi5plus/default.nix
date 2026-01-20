{
  ...
}:

{
  imports = [
    ../../hardware/orangepi5plus/default.nix
    ../../common/base.nix
    ../../common/tma-base.nix
  ];

  boot.initrd.systemd.enable = true;

  networking.hostName = "tma-orangepi5plus";

  system.stateVersion = "24.05";

}
