self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.6.14";
    commit = "9ba4b250366a5ddde94bb7c9d1def331423aa323";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "+2K2lLxTXZS8pjgqhJZd+JovUFqG5Cgw9iAbDjnUvvQ=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
