self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.22";
    commit = "7f7fdf5fed64eb6a7caf99b3e12efcf9d60e311c";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-8IHBKai4PvvTuHPDTgx9wFEBzz4MM7Mwo8Q/bzFRzfk=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
