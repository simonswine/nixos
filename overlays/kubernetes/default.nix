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
    kver = "1.18.18";
    khash = "1k1x3hr2zjpahipvjs6nbsx5v7apjgmymxrp3h294vcqddqnc3ch";
  };

  "kubernetes-1-19" = kubernetesVersion {
    kver = "1.19.10";
    khash = "0bjj6h5607zqa6dnvk306i8v8dvrj6v0lm530023yxa623g28hg3";
  };

  "kubernetes-1-20" = kubernetesVersion {
    kver = "1.20.6";
    khash = "1x5khnwl57vhlpc3949jijlszkpq7k0f367b7j9l7alvwj79x3x2";
  };
}
