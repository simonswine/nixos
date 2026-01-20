{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.virtualisation.containerd-kubelet;
in
{
  options.virtualisation.containerd-kubelet = {
    enable = mkEnableOption "containerd as kubelet container runtime";

    kata = {
      enable = mkEnableOption "enable kata container runtime";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.kata-runtime;
        defaultText = lib.literalExpression "pkgs.kata-runtime";
        description = "Configured kata-runtime  package.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.cri-tools
    ]
    ++ lib.optional cfg.kata.enable cfg.kata.package;
    environment.etc."crictl.yaml".text = ''
      runtime-endpoint: unix:///run/containerd/containerd.sock
    '';

    virtualisation.containerd = {
      enable = true;
      settings = {
        version = 2;
        oom_score = -999;
        metrics = {
          address = "127.0.0.1:1338";
        };
        plugins = {
          "io.containerd.grpc.v1.cri" = {
            containerd = {
              default_runtime_name = "runc";
              snapshotter = "zfs";
              runtimes = {
                runc = {
                  runtime_type = "io.containerd.runc.v2";
                  options = {
                    SystemdCgroup = true;
                  };
                };
              }
              // lib.optionalAttrs cfg.kata.enable {
                kata = {
                  runtime_type = "io.containerd.kata.v2";
                };
              };
            };
            cni.bin_dir = "/opt/cni/bin";
            sandbox_image = "registry.k8s.io/pause:3.10";
          };
          "io.containerd.transfer.v1.local" = {
            unpack_config = [
              {
                platform = "linux/amd64";
                snapshotter = "zfs";
              }
            ];
          };
        };

      };
    };

    ## TODO: environment.etc."cni/net.d/10-containerd-bridge.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/10-containerd-bridge.conf";
    ## TODO: environment.etc."cni/net.d/99-loopback.conf".source = copyFile "${pkgs.containerd-unwrapped.src}/contrib/cni/99-loopback.conf";

    systemd.services.containerd = {
      path = [
        pkgs.zfs
        pkgs.iptables-nftables-compat
      ]
      ++ lib.optional cfg.kata.enable cfg.kata.package;
      serviceConfig = {
        # This limit was reduce from infinty to 1024:524288 as part of nixos 24.11. Raising that limit slightly.
        LimitNOFILE = "32768:524288";
      };
    };
  };
}
