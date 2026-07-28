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
  kubernetes-1-34 = kubernetesVersion {
    kver = "1.34.10";
    khash = "sha256-NN9BWQIK+B39FLbD4nTbV9M2fAXw7va9GLD3HgOdpuk=";
  };

  kubernetes-1-35 = kubernetesVersion {
    kver = "1.35.7";
    khash = "sha256-GcAc071Ueka7P5kVTIwCNu6FBH/9xhWYfKdtaLAk4Fc=";
  };

  kubernetes-1-36 = kubernetesVersion {
    kver = "1.36.3";
    khash = "sha256-yqxE+it+uYQrJJs3TJI2D6IQRJizieUQyPQMLIOPWqA=";
  };

}
