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
    kver = "1.20.14";
    khash = "4knYDSvBYJ+BkmRz87M8bcevtmgaQyaKdPYjsqEJrBg=";
  };

  kubernetes-1-21 = kubernetesVersion {
    kver = "1.21.8";
    khash = "h47tjn+o4q/DvtS2rpaBvNyw7Cu9iu0Ou7LmE0WmH04=";
  };

  kubernetes-1-22 = kubernetesVersion {
    kver = "1.22.5";
    khash = "Hj9npIUwMqfYtTsuLvgk04KDlLixefLT2L23S7JOcM4=";
  };
}
