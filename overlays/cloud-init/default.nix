self: super:
{
  cloud-init = super.cloud-init.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./zfs-zpool-status.patch
    ];

    postInstall = old.postInstall + ''
      mkdir -p $out/libexec/cloud-init/
      ln -s ../write-ssh-key-fingerprints $out/libexec/cloud-init/write-ssh-key-fingerprints
    '';

  });
}
