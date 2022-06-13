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

      nativeBuildInputs = [ super.makeWrapper super.which super.go_1_18 super.rsync super.installShellFiles ];

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
  kubernetes-1-21 = kubernetesVersion {
    kver = "1.21.13";
    khash = "iqYmLo5tg6p/H4LitA3TYLMYWXT3bM5PNOvEMwUMMyI=";
  };

  kubernetes-1-22 = kubernetesVersion {
    kver = "1.22.10";
    khash = "2q/38sHr4lQiYkscNZZPPHKJ/nJ/Tfoj05dMZk3w0PI=";
  };

  kubernetes-1-23 = kubernetesVersion {
    kver = "1.23.7";
    khash = "YHlcopB47HVLO/4QI8HxjMBzCpcHVnlAz3EOmZI+EG8=";
  };

  kubernetes-1-24 = kubernetesVersion {
    kver = "1.24.1";
    khash = "Sia0bM121IWLTFSacs0cNqiqKtsdfG6jV597bNk4raI=";
  };
}
