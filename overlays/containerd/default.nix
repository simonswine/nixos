self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "2.1.3";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-MqHcwomsVYbjziO0vIpGAcREChe5mbJVGsvM96bszLA=";
    };
    makeFlags =
      builtins.filter
        (x:
          (!super.lib.strings.hasPrefix "VERSION=" x) &&
          (!super.lib.strings.hasPrefix "REVISION=" x)
        )
        old.makeFlags
      ++
      [
        "REVISION=${src.rev}"
        "VERSION=v${version}"
      ];
  });
}
