self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.4.6";
    commit = "d71fcd7d8303cbf684402823e425e9dd2e99285d";
    src = super.fetchFromGitHub {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      sha256 = "1an4gzg7fz24nq7vb3k8ddv5r0s98x88mz0z67197brsmi4pwy58";
    };
  });
}
