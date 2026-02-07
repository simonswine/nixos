self: super:
let
  upstream = super.kubernetes.override {
    components = [
      "cmd/kubeadm"
      "cmd/kubectl"
      "cmd/kubelet"
    ];

  };

  kubernetesVersion =
    { kver, khash }:
    upstream.overrideAttrs (old: rec {
      version = kver;

      src = super.fetchFromGitHub {
        owner = "kubernetes";
        repo = "kubernetes";
        rev = "v${version}";
        sha256 = khash;
      };

      installPhase = ''
        runHook preInstall
        for p in $WHAT; do
          install -D _output/local/go/bin/''${p##*/} -t $out/bin
        done
        cc build/pause/linux/pause.c -o pause
        install -D pause -t $pause/bin
        rm docs/man/man1/kubectl*
        installManPage docs/man/man1/*.[1-9]

        installShellCompletion --cmd kubectl \
          --bash <($out/bin/kubectl completion bash) \
          --fish <($out/bin/kubectl completion fish) \
          --zsh <($out/bin/kubectl completion zsh)

        installShellCompletion --cmd kubeadm \
          --bash <($out/bin/kubeadm completion bash) \
          --zsh <($out/bin/kubeadm completion zsh)
        runHook postInstall
      '';

    });
in
{
  kubernetes-1-32 = kubernetesVersion {
    kver = "1.32.11";
    khash = "/Hg0yf7Y8My+g3w36fA94ozCzhmI0sMjpF7FPZ/UykY=";
  };

  kubernetes-1-33 = kubernetesVersion {
    kver = "1.33.7";
    khash = "439MCwbt6XRhKi+6wbyro33ptS//uIv0TeL2NQ/tD7M=";
  };

  kubernetes-1-34 = kubernetesVersion {
    kver = "1.34.3";
    khash = "1X2kxUi7jNnyTNo+ZGZmhU5DHVl98eYOrJ4qpjzqqjE=";
  };

  kubernetes-1-35 = kubernetesVersion {
    kver = "1.35.0";
    khash = "AT1/4RhnVK/mAoNVqPIfSwbzD8VNRqKumOpE0fidJ74=";
  };
}
