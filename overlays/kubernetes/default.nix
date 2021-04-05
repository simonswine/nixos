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
    khash = "1iw1r04ghyd1dlq0lhj4gnx02kxa7x7a4l7q5gwc2m5m69nqlav3";
  };

  "kubernetes-1-19" = kubernetesVersion {
    kver = "1.19.9";
    khash = "11jdbl4l5arnsh26axld0fa26sdwx55a3wr3sm38rdcx5fvlmcgm";
  };

  "kubernetes-1-20" = kubernetesVersion {
    kver = "1.20.5";
    khash = "1f9qy8rzal0c3zyd25zsv49zk9lqdv8s77f8bff0pd2kv7p86dj4";
  };
}
