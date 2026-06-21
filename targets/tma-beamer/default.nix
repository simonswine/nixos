{
  inputs,
  ...

}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ../../common/base.nix
    ../../common/tma-base.nix
  ];

  boot.initrd.systemd = {
    enable = true;
    tpm2.enable = false;
  };

  networking.hostName = "tma-beamer";

  system.stateVersion = "24.05";

}
