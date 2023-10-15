self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.7";
    commit = "8c087663b0233f6e6e2f4515cee61d49f14746a8";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "5Tw7xltrsp+yGrdJ0O4MoFUvIaEiCQpMip5X1kfV/iM=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
