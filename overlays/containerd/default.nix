self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.5.9";
    commit = "1407cab509ff0d96baa4f0eb6ff9980270e6e620";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "v5seKJMfZUVMbydxKiTSy0OSwen6I/3DrGJnL2DyqHg=";
    };
    buildFlags = [ "VERSION=v${version}" "REVISION=${commit}" ];
  });
}
