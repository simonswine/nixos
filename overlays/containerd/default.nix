self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.25";
    commit = "bcc810d6b9066471b0b6fa75f557a15a1cbf31bb";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-T0F5bwxSCqa4Czs/W01NaAlJJFvgrzkBC1y/r+muivA=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
