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
  kubernetes-1-33 = kubernetesVersion {
    kver = "1.33.12";
    khash = "sha256-c4aYdqssZSCXxoLwaEf5sGOFK2XmfkE9Acd40sU7gso=";
  };

  kubernetes-1-34 = kubernetesVersion {
    kver = "1.34.7";
    khash = "sha256-pDSVKgFIcMUDiy0BWx/VadwuatteUwmctaNbCLY4Yhg=";
  };

  kubernetes-1-35 = kubernetesVersion {
    kver = "1.35.4";
    khash = "sha256-UXYkReGD77Uu0P0iYvkK58Uj0f7CuXGMb1WJBD7/61U=";
  };
}
