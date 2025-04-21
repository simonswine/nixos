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
  kubernetes-1-30 = kubernetesVersion {
    kver = "1.30.11";
    khash = "00IMTe5jhaagrYk58d5zsTfumlw63BPIJmRk77EfHOg=";
  };

  kubernetes-1-31 = kubernetesVersion {
    kver = "1.31.7";
    khash = "o5DEo+ahi87Z+0Gw/SNFWZL+Sjjcu4SY38YCw1t+0Pk=";
  };

  kubernetes-1-32 = kubernetesVersion {
    kver = "1.32.3";
    khash = "kF3Oo+YETnsrFPWBO5b7nH2A2eONIOkE84+u6vOSrpE=";
  };
}
