self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.9";
    commit = "4f03e100cb967922bec7459a78d16ccbac9bb81d";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-/kCnzOL8CJuJJglHzmev3alt8cMwTUbIiZhNft9zwps=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
