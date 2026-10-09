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
        hash = khash;
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
  kubernetes-1-35 = kubernetesVersion {
    kver = "1.35.9";
    khash = "sha256-y7GR3hDcWiFBbpJBAGTsTM70jqo7jss4Flqb9udhnCs=";
  };

  kubernetes-1-36 = kubernetesVersion {
    kver = "1.36.5";
    khash = "sha256-M5wVu5678Eow6xMLNZXcfPLlS9z11RpwwzvmYd8NEeE=";
  };

  kubernetes-1-37 = kubernetesVersion {
    kver = "1.37.1";
    khash = "sha256-9p7t8EN6Iv3Q2ClJgCgSUJP1Qdp7B47fOe0roP5jZbg=";
  };

}
