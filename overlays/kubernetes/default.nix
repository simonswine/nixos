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
    kver = "1.23.17";
    khash = "H1HuA+eJzYNRIxscJpimH/AKFJM/ijOd8yrN9E/PZQ8=";
  };

  kubernetes-1-24 = kubernetesVersion {
    kver = "1.24.15";
    khash = "S3mj2mxyP5GfWQlB5JN4HdNFdsGuyzm37JoKY8HVXOg=";
  };

  kubernetes-1-25 = kubernetesVersion {
    kver = "1.25.11";
    khash = "d68ToezmQlyjBqDWWWmr8uzo/KDIMvHtLqFfWfXyDuY=";
  };

  kubernetes-1-26 = kubernetesVersion {
    kver = "1.26.6";
    khash = "JpUys0J5JcBRn6P+bjROA5caDF6Q5xeRhx7/MT+Vdso=";
  };
}
