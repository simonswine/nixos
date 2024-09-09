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
    kver = "1.28.13";
    khash = "dPLSbHStUVHm7SjjZkQvGZV2sNtsxPc6kCWeEaOIrmw=";
  };

  kubernetes-1-29 = kubernetesVersion {
    kver = "1.29.8";
    khash = "NnkUsqXz/H25kQz2m7C//gNVXvHNpjnUy7JY52ou1zk=";
  };

  kubernetes-1-30 = kubernetesVersion {
    kver = "1.30.4";
    khash = "Ob4fezYEj9RPt5tc0c9ms0+t4/DWib4mMrYL1rCmcvw=";
  };
}
