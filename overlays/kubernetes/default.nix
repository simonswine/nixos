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
    kver = "1.20.10";
    khash = "57Cs2/AVHmnT5uS0Tp0NQZLOovUKOkeX87/stx6ZtXY=";
  };

  "kubernetes-1-21" = kubernetesVersion {
    kver = "1.21.4";
    khash = "1xOF7C6N9OUvHm0dhqBSTihprZ30+iyJEhpJd70qZyo=";
  };
}
