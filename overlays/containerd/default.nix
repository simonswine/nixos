self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.26";
    commit = "753481ec61c7c8955a23d6ff7bc8e4daed455734";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-1+WtmRCrLbf5AwOAp+3PKPkGKI9yZqJcJOyS4uR0bmg=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
