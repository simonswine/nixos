self: super:
{
  cloud-init = super.pkgs.callPackage ../../pkgs/cloud-init { };
}
