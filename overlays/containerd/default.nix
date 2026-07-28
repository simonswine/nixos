self: super: {
  containerd =
    (super.containerd.override {
      buildGoModule = super.buildGoModule.override { go = super.go_1_26; };
    }).overrideAttrs
      (old: rec {
        version = "2.3.3";
        src = super.fetchFromGitHub {
          owner = "containerd";
          repo = "containerd";
          rev = "v${version}";
          hash = "sha256-wa9Pixaq5RRrJucWibbBe4n6s53Pdj+mr5gLoFmDgLU=";
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
