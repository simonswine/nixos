self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.6";
    commit = "091922f03c2762540fd057fba91260237ff86acb";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "9at1o+zzrCcWGW5RlkyG1BBA5a547e5uJ6NQllsXFpw=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
