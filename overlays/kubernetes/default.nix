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
  kubernetes-1-26 = kubernetesVersion {
    kver = "1.26.15";
    khash = "zegGiZM3nCxbYzwtTTgbzphAerdigSyxESpmmK3HSgI=";
  };

  kubernetes-1-27 = kubernetesVersion {
    kver = "1.27.15";
    khash = "d74YbTvnJerOGyh80mXTONs+B38kC4SVs8xsED8JEu0=";
  };

  kubernetes-1-28 = kubernetesVersion {
    kver = "1.28.11";
    khash = "A8aFK1+2SbSP90Vb5NZ2y5vLi8pEPKUH199IG003NAI=";
  };

  kubernetes-1-29 = kubernetesVersion {
    kver = "1.29.6";
    khash = "wedk7Vm15s91zRWBgYlvfmsx8IoR2jt4Oc3AED6e4Rk=";
  };
}
