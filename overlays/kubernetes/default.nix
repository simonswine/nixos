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
    kver = "1.21.13";
    khash = "iqYmLo5tg6p/H4LitA3TYLMYWXT3bM5PNOvEMwUMMyI=";
  };

  kubernetes-1-22 = kubernetesVersion {
    kver = "1.22.10";
    khash = "2q/38sHr4lQiYkscNZZPPHKJ/nJ/Tfoj05dMZk3w0PI=";
  };

  kubernetes-1-23 = kubernetesVersion {
    kver = "1.23.7";
    khash = "YHlcopB47HVLO/4QI8HxjMBzCpcHVnlAz3EOmZI+EG8=";
  };
}
