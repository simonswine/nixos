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

      nativeBuildInputs =
        let
          go =
            if builtins.compareVersions kver "1.24.0" >= 0
            then super.go_1_18
            else super.go_1_17;
        in
        [ super.makeWrapper super.which go super.rsync super.installShellFiles ];

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
    kver = "1.21.14";
    khash = "6LxkLqQMmCncndd4RXLmN04su2IsBXQDWMB7NYoG4is=";
  };

  kubernetes-1-22 = kubernetesVersion {
    kver = "1.22.13";
    khash = "rXWia+45NY8+9jnf52nTXE1YwvusickHn/Pu+NRvY2o=";
  };

  kubernetes-1-23 = kubernetesVersion {
    kver = "1.23.10";
    khash = "ujSy6akbk4SvMIQdBJkNMwaRNEfFKJmVrN3lNtFudkA=";
  };

  kubernetes-1-24 = kubernetesVersion {
    kver = "1.24.4";
    khash = "8lkNJ3OV4t/47LsaGgu7rOhuedCsDmU5QRoLDPuFbjc=";
  };
}
