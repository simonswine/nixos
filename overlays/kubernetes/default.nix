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
    kver = "1.23.15";
    khash = "NLNewD3ky/ZV1bn4eWW6yLmRiDdWV3+FV6uTXyWnxZo=";
  };

  kubernetes-1-24 = kubernetesVersion {
    kver = "1.24.9";
    khash = "/RFCNjbDM+kNPm7sbJjtZGBO9RD3F61Un3gjPZqzH9s=";
  };

  kubernetes-1-25 = kubernetesVersion {
    kver = "1.25.5";
    khash = "HciTzp9N7YY1+jzIJY8OPmYIsGfe/5abaExnDzt1tKE=";
  };
}
