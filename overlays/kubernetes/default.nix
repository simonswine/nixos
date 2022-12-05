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
  kubernetes-1-23 = kubernetesVersion {
    kver = "1.23.14";
    khash = "IXH7PyKg5cdZSOWXUoy/c5k0mYo6B+WQd/3D2U8t5Mc=";
  };

  kubernetes-1-24 = kubernetesVersion {
    kver = "1.24.8";
    khash = "QmhRTtJHU12C0vsFe2RRM3SYqaFe1aqGx0Irf4Gy1zY=";
  };

  kubernetes-1-25 = kubernetesVersion {
    kver = "1.25.4";
    khash = "1k0L8QUj/764X0Y7qxjFMnatTGKeRPBUroHjSMMe5M4=";
  };
}
