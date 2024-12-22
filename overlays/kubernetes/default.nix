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
  kubernetes-1-28 = kubernetesVersion {
    kver = "1.28.15";
    khash = "E9NO9L1pV5Whn/H3/Kst4u+7B9Qx63A9bGRBrE21nDE=";
  };

  kubernetes-1-29 = kubernetesVersion {
    kver = "1.29.12";
    khash = "j6mY1mY4NCL3fmz01o85DhuE65R9543owvyioDK54eI=";
  };

  kubernetes-1-30 = kubernetesVersion {
    kver = "1.30.8";
    khash = "GdLIxuQaHJ3+DF+Furvca4D2Vw0OGbbFKtCCkyR6TSQ=";
  };

  kubernetes-1-31 = kubernetesVersion {
    kver = "1.31.4";
    khash = "XEilva/K2xGZHhrifaK/f4a3PGPb5dClOqv1dlJOTCM=";
  };
}
