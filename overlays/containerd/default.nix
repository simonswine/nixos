self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "2.2.1";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-fDOfN0XESrBTDW7Nxj9niqU93BQ5/JaGLwAR3u6Xaik=";
    };
    makeFlags =
      builtins.filter (
        x: (!super.lib.strings.hasPrefix "VERSION=" x) && (!super.lib.strings.hasPrefix "REVISION=" x)
      ) old.makeFlags
      ++ [
        "REVISION=${src.rev}"
        "VERSION=v${version}"
      ];
  });
}
