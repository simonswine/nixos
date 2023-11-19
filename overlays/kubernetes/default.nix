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

      installPhase =
        ''
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

    }
  );
in
{
  kubernetes-1-24 = kubernetesVersion {
    kver = "1.24.17";
    khash = "js0NhYL5WCvlufEyYUvk9xVlbU7minpinn7w/QY+CnA=";
  };

  kubernetes-1-25 = kubernetesVersion {
    kver = "1.25.16";
    khash = "Je+PeMF7Ivg5gD/y8l0piXfO60/TClz28lyvyyCnXkA=";
  };

  kubernetes-1-26 = kubernetesVersion {
    kver = "1.26.11";
    khash = "0xOiVivkZF85kUI9LdAsoWdth966cMGjOxspeVVpQAc=";
  };

  kubernetes-1-27 = kubernetesVersion {
    kver = "1.27.8";
    khash = "90tmK7OcEeCdKHYN3aWrGrnv+yiVTx62cPllo+IA4PQ=";
  };

  kubernetes-1-28 = kubernetesVersion {
    kver = "1.28.4";
    khash = "aaGcAIyy0hFJGFfOq5FaF0qAlygXcs2WcwgvMe5dkbo=";
  };
}
