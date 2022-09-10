self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.6.8";
    commit = "9cd3357b7fd7218e4aec3eae239db1f68a5a6ec6";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "0UiPhkTWV61DnAF5kWd1FctX8i0sXaJ1p/xCMznY/A8=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
