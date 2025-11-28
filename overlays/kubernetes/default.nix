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
    kver = "1.31.14";
    khash = "rfYv9VlXKdQNcR1AiMv7wVeyJYHq5qJPw9g15sn3U40=";
  };

  kubernetes-1-32 = kubernetesVersion {
    kver = "1.32.10";
    khash = "8N6Qo0Qqg+lTvBzA6H6lOTWSMxUbjQh1U4iqZ2V679c=";
  };

  kubernetes-1-33 = kubernetesVersion {
    kver = "1.33.6";
    khash = "ywmaMRtq/HqkHO4CGspL4AYcn4IbFzAzA0xZRmAgCWE=";
  };

  kubernetes-1-34 = kubernetesVersion {
    kver = "1.34.2";
    khash = "3rQyoGt9zTeF8+PIhA5p+hHY1V5O8CawvKWscf/r9RM=";
  };
}
