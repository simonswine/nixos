self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.14";
    commit = "dcf2847247e18caba8dce86522029642f60fe96b";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-okTz2UCF5LxOdtLDBy1pN2to6WHi+I0jtR67sn7Qrbk=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
