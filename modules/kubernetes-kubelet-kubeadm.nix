{ config, lib, pkgs, ... }:

with lib;
let
  top = config.services.kubernetes;
  cfg = top.kubelet-kubeadm;

  deps = with pkgs; [ ethtool socat iptables iptables-nftables-compat conntrack-tools ];
in
{
  ###### interface
  options.services.kubernetes.kubelet-kubeadm = with lib.types; {
    enable = mkEnableOption "Kubernetes kubelet for kubeadm.";

    cni = {
      packages = mkOption {
        description = "List of network plugin packages to install.";
        type = listOf package;
        default = [ pkgs.cni-plugins ];
      };
    };
  };

  ###### implementation
  config = mkMerge [
    (mkIf cfg.enable {

      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
      boot.kernel.sysctl."net.bridge.bridge-nf-call-iptables" = 1;
      boot.kernel.sysctl."net.bridge.bridge-nf-call-ip6tables" = 1;

      # restrict access to kernel logs
      boot.kernel.sysctl."kernel.dmesg_restrict" = 1;

      environment.systemPackages = deps ++ [ top.package pkgs.cri-tools ];

      systemd.tmpfiles.rules = [
        "d /etc/kubernetes/manifests 0755 root root -"
        "d /opt/cni/bin 0755 root root -"
        "d /run/kubernetes 0755 root root -"
        "d /var/lib/kubernetes 0755 root root -"
      ];

      systemd.services.kubelet = {
        description = "kubelet: The Kubernetes Node Agent";
        documentation = [ "https://kubernetes.io/docs/home/" ];
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        path = with pkgs; [ gitMinimal openssh utillinux iproute thin-provisioning-tools ] ++ deps ++ top.path;

        preStart = ''
                    ${concatMapStrings
          (package: ''
                      echo "Linking cni package: ${package}"
                      for x in ${package}/bin/*; do
                        dest="/opt/cni/bin/$(basename "''${x}")"
                        if [[ -x "''${dest}" && ! -L ''${dest} ]]; then
                          echo "''${dest} continue"
                          continue
                        fi
                        ln -sf "''${x}" "''${dest}"
                      done
                    '')
          cfg.cni.packages}
        '';

        unitConfig = {
          StartLimitInterval = "0";
        };

        serviceConfig = {
          Slice = "kubernetes.slice";
          CPUAccounting = true;
          MemoryAccounting = true;
          Restart = "on-failure";
          RestartSec = "10s";
          EnvironmentFile = [
            "-/var/lib/kubelet/kubeadm-flags.env"
            "-/etc/default/kubelet"
          ];
          Environment = [
            ''"KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"''
            ''"KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"''
          ];
          ExecStart = "${top.package}/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS";
          WorkingDirectory = top.dataDir;
        };
      };

      # Allways include cni plugins
      services.kubernetes.kubelet.cni.packages = [ pkgs.cni-plugins ];

      # disable nixos firewall for kubernetes
      networking.firewall.enable = false;

      boot.kernelModules = [ "br_netfilter" ];

    })
  ];
}
