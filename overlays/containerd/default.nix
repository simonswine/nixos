self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.24";
    commit = "88bf19b2105c8b17560993bee28a01ddc2f97182";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-03vJs61AnTuFAdImZjBfn1izFcoalVJdVs9DZeDcABI=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
