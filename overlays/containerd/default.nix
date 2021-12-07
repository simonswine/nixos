self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.5.8";
    commit = "1e5ef943eb76627a6d3b6de8cd1ef6537f393a71";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "XIAByE2/eVG8DAZXstKs51LQYdVPcPQuIlST3xCclrU=";
    };
    buildFlags = [ "VERSION=v${version}" "REVISION=${commit}" ];
  });
}
