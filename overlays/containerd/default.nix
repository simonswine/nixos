self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.6.19";
    commit = "1e1ea6e986c6c86565bc33d52e34b81b3e2bc71f";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "Us7NEv2BngV1Q/Bkuv4XOjVjpqThL0LnIH+yciPG3L8=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
