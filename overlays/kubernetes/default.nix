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
  kubernetes-1-21 = kubernetesVersion {
    kver = "1.21.11";
    khash = "LvmWKVzwFOO654dveRZ+55OzVZOu26QCwuucflIbjXw=";
  };

  kubernetes-1-22 = kubernetesVersion {
    kver = "1.22.8";
    khash = "9TO5cBMlbElU3wRZY7Mnr3aFq+ywa2JkujdAKL/cxkE=";
  };

  kubernetes-1-23 = kubernetesVersion {
    kver = "1.23.5";
    khash = "LhJ3gThcsWnawSOmHSzWOG8tfODIPo4dJTMeLKmvMdM=";
  };
}
