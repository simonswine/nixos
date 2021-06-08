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

#      postBuild = ''
#        mkdir -p docs/man/man1
#      '' +
#      (if (
#        (super.lib.versions.major kver) >= "1"
#          &&
#          (super.lib.versions.minor kver) >= "20"
#      )
#      then
#        ''
#          (cd build/pause/linux && cc pause.c -o pause && mv pause ..)
#        ''
#      else
#        ''
#          (cd build/pause && cc pause.c -o pause)
#        ''
#      );
    }
  );
in
{
  "kubernetes-1-20" = kubernetesVersion {
    kver = "1.20.7";
    khash = "06s44mj59mjsk09gcn3xcly01rqkam4hbsi1w8l7x8wjribm9q1s";
  };

  "kubernetes-1-21" = kubernetesVersion {
    kver = "1.21.1";
    khash = "1xz4kkyh7ygs8hd52ab0a3hhvrl137iiz4c8j0ylxa8jdz1w5640";
  };
}
