{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
# Image format module for the KubeVirt container disk, inlined from
# nix-community/nixos-generators 1.4.0 (formats/qcow.nix). That project is
# archived and its CLI no longer works against current nixpkgs, since it calls
# `override` on the result of `lib.nixosSystem`, which only provides
# `extendModules` these days. The format itself is a thin wrapper around
# nixpkgs' own make-disk-image.nix, so it is kept here directly.
#
# This is what supplies the root filesystem and bootloader for the VM, which is
# why targets/kubevirt-vpn/default.nix does not define them itself.
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  boot.growPartition = true;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = lib.mkDefault "/dev/vda";
  boot.loader.timeout = 0;

  system.build.qcow = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = 8192;
    format = "qcow2";
  };
}
