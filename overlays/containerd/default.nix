self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.2";
    commit = "0cae528dd6cb557f7201036e9f43420650207b58";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "L4zaA+kMBz2tRMbitZUxb9/wdimSO2njx6ozvyKKlkk=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
