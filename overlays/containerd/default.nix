self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.5.7";
    commit = "8686ededfc90076914c5238eb96c883ea093a8ba";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "BHVlGXyTkaiRkG8WG1LdtxrQs8nKS8djZFnO/AfKBUw=";
    };
    buildFlags = [ "VERSION=v${version}" "REVISION=${commit}" ];
  });
}
