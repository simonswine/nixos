self: super: {
  containerd =
    (super.containerd.override {
      buildGoModule = super.buildGoModule.override { go = super.go_1_26; };
    }).overrideAttrs
      (old: rec {
        version = "2.4.1";
        src = super.fetchFromGitHub {
          owner = "containerd";
          repo = "containerd";
          rev = "v${version}";
          hash = "sha256-wp4cP3kYm1k9ZPj9B37dQx8//1Ept8aIfZseob9Nyv0=";
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
