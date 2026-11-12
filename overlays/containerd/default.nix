self: super: {
  containerd =
    (super.containerd.override {
      buildGoModule = super.buildGoModule.override { go = super.go_1_26; };
    }).overrideAttrs
      (old: rec {
        version = "2.4.2";
        src = super.fetchFromGitHub {
          owner = "containerd";
          repo = "containerd";
          rev = "v${version}";
          hash = "sha256-RP1qn/dlfVCAwe3ZxASStzGZmuYwdUVwfPGG8XByNNk=";
        };
        patches = (old.patches or [ ]) ++ [
          # Remap hard-linked inodes only once in the user-namespace fallback.
          ./userns-hardlinks.patch
          # Avoid recursively walking Btrfs snapshots when quotas are enabled.
          # https://github.com/cono/gentoo-portage/blob/main/app-containers/containerd/files/containerd-2.3.4-btrfs-qgroup-usage.patch
          ./btrfs-qgroup-usage.patch
        ];
        makeFlags =
          builtins.filter (
            x: (!super.lib.strings.hasPrefix "VERSION=" x) && (!super.lib.strings.hasPrefix "REVISION=" x)
          ) old.makeFlags
          ++ [
            "REVISION=${src.rev}"
            "VERSION=v${version}"
          ];
      });
}
