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
    kver = "1.21.9";
    khash = "RE3JvQ06G02etba0JhQ/2OIPlGz5lrEn+G4deQG/d34=";
  };

  kubernetes-1-22 = kubernetesVersion {
    kver = "1.22.6";
    khash = "NL00GOdkVLVHTlj1RK1+stssioy+0xbtiKn4FZnCuzs=";
  };

  kubernetes-1-23 = kubernetesVersion {
    kver = "1.23.3";
    khash = "Ccf+9mwDv1Fs0+xN8yDkUjh4A3aGox7rBGesyYtkUDs=";
  };
}
