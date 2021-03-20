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

      postBuild = ''
        mkdir -p docs/man/man1
      '' +
      (if (
        (super.lib.versions.major kver) >= "1"
          &&
          (super.lib.versions.minor kver) >= "20"
      )
      then
        ''
          (cd build/pause/linux && cc pause.c -o pause && mv pause ..)
        ''
      else
        ''
          (cd build/pause && cc pause.c -o pause)
        ''
      );
    }
  );
in
{
  "kubernetes-1-18" = kubernetesVersion {
    kver = "1.18.17";
    khash = "1ckzxviyiz3pmfad99p810yawzb74z3zdd9icn8qyfkac8z1cl2s";
  };

  "kubernetes-1-19" = kubernetesVersion {
    kver = "1.19.9";
    khash = "0642bjggm3fpd772623agqbvn1dbs7gcpf5m2l26m03rxpzmp5qp";
  };

  "kubernetes-1-20" = kubernetesVersion {
    kver = "1.20.5";
    khash = "1f9qy8rzal0c3zyd25zsv49zk9lqdv8s77f8bff0pd2kv7p86dj4";
  };
}
