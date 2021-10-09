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
  kubernetes-1-20 = kubernetesVersion {
    kver = "1.20.11";
    khash = "bJwixxrY+gC28qAdq6xAN4FumBRWT5dzpEGvrwTuv3w=";
  };

  kubernetes-1-21 = kubernetesVersion {
    kver = "1.21.5";
    khash = "pZJAAoUzf8VdJ2Wx1UUGMNOD7mAqCot2LtmylU9HGo8=";
  };

  kubernetes-1-22 = kubernetesVersion {
    kver = "1.22.2";
    khash = "O+FY9wJ0fztO7i5qJfw+cfhfBgaMWKX7IBBXJV4uuCk=";
  };
}
