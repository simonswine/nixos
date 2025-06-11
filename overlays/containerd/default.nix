self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "2.1.1";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-ZqQX+bogzAsMvqYNKyWvHF2jdPOIhNQDizKEDbcbmOg=";
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
