self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.5.11";
    commit = "3df54a852345ae127d1fa3092b95168e4a88e2f8";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "BbWNrPRISGoJAo8TXE5lmjLlEKe0t1wq1/yJnbq5Ejo=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries man "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
