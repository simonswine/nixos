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
  kubernetes-1-31 = kubernetesVersion {
    kver = "1.31.11";
    khash = "w4pVk2J7LuU2jbyklmOZSUrB1AwIzusQgxp89OdtK1I=";
  };

  kubernetes-1-32 = kubernetesVersion {
    kver = "1.32.7";
    khash = "64002KyKgITobf4WCVgA1TQwJmnIG9rVUuuq8wPYKn4=";
  };

  kubernetes-1-33 = kubernetesVersion {
    kver = "1.33.3";
    khash = "UZdrfQEEx0RRe4Bb4EAWcjgCCLq4CJL06HIriYuk1Io=";
  };
}
