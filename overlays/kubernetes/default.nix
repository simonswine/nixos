self: super:
let
  upstream = super.kubernetes.override {
    components = [
      "cmd/kubeadm"
      "cmd/kubectl"
      "cmd/kubelet"
    ];
  };

  kubernetesVersion = { kver, khash }: upstream.overrideAttrs (
    old: rec {
      version = kver;

      src = super.fetchFromGitHub {
        owner = "kubernetes";
        repo = "kubernetes";
        rev = "v${version}";
        sha256 = khash;
      };
    }
  );
in
{
  "kubernetes-1-20" = kubernetesVersion {
    kver = "1.20.9";
    khash = "alwQ2gNi4gJ9PCwThdKPp59Kv1+cC1BLdYQ1mKKmTKg=";
  };

  "kubernetes-1-21" = kubernetesVersion {
    kver = "1.21.3";
    khash = "GMigdVuqJN6eIN0nhY5PVUEnCqjAYUzitetk2QmX5wQ=";
  };
}
