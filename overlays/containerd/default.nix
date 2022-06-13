self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.6.6";
    commit = "10c12954828e7c7c9b6e0ea9b0c02b01407d3ae1";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "cmarbad6VzcGTCHT/NtApkYsK/oo6WZQ//q8Fvh+ez8=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
