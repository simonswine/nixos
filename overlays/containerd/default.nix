self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.5.5";
    commit = "72cec4be58a9eb6b2910f5d10f1c01ca47d231c0";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "6mDTTXHpXBcKOcT+VrGgt6HJzvTeKgJ0ItJ+IjCTJxk=";
    };
    buildFlags = [ "VERSION=v${version}" "REVISION=${commit}" ];
  });
}
