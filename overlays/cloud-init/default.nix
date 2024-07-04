self: super:
{
  cloud-init = super.cloud-init.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./zfs-zpool-status.patch
    ];
  });
}
