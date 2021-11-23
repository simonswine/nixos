{ config, pkgs, lib, ... }:
let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQ5dGULRFzfKTZPYk9OG95EL/hvE/F8zqHTUHtXTYIt 2017-ed25519-simon@swine.de"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCh2jwszS843PG/pCib2YGAyx6GdtBllxFlUtoAPXHFtD0cXcM7Ckza+uHTHrNuSIOmFP7f7wSi3ANTBOvuQAB9JWWkQ7nyqzeErFqx9EEutJ7uDrj5V6Bn4f1Gj2KAOo6qH1TQ7zPUm4GTjsLitsN3fAu4NASSuTbBZdtSWYwNjZ/+mG2UR4pXFW599UoKw2Aok5w3WadCGGdj/jMNG5uQ1IhI6gv6z4seMqKvGhgHBwO+ujcxDMWcgMsp1A2nG9dGpLAic7KV9Z3UkzfaDDZwRuvSRazFGhfBqqZV3NcgMYVQ6lZ+x+yUQHIDgY+3OS7VCN32DLzCw9ryC0xf2848g+5EjWWuxwaMJH0qTZUNzKQgSDSBXJP2R9HNOmqhrZqw9GqfUWbpnuo+8l1ssFQWcnM0UmBDdyJ0dJRwnuTt6PObjTug/c2iUBAlB+Lgw+42GJCWjiAK8e52ahG6Xt7FlhMlqSVQLzfei2jfSpzSQ1j//ZNuidPQrDR5kLvcKh2Xn8FmN/eyTxIgMA1a4cybSex4xIDL9FGnjrjF6nwk+4TwgtPHbVl4LCNj1nKmQAbpMgxXpQo2gEUlvjCzJ6WWcYP4vmLLDC7CcIG4zVPpL2X7BpH5EW6B9/TD/2RfHA7qiCoAah3czN5WmIRZbSsCoPF3DSGuk626Ap0hOO9wwQ== 2017-rsa-simon@swine.de"
  ];
in

{
  boot.initrd.availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];
  boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];

  boot.initrd.postDeviceCommands =
    ''
      # Set the system time from the hardware clock to work around a
      # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
      # to the *boot time* of the host).
      hwclock -s
    '';

  # use networkd
  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;

  # set hostname using DNS
  networking.hostName = "";
  networking.wireguard.enable = true;
  networking.firewall.enable = false;

  environment.systemPackages = with pkgs;
    [
      vim
      git
      wireguard-tools
      kubectl
    ];

  environment.variables = {
    "KUBERNETES_SERVICE_HOST" = "172.16.0.1";
    "KUBERNETES_SERVICE_PORT" = "443";
  };

  services.prometheus.exporters =
    {
      wireguard.enable = true;
      openvpn = {
        enable = true;
        statusPaths = [ "/etc/openvpn/swine.status" ];
      };
    };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.root =
    {
      openssh.authorizedKeys.keys = authorizedKeys;
    };

  # mount wireguard config
  fileSystems."/run/secrets/wireguard" =
    {
      device = "/dev/disk/by-id/virtio-wireguard-config";
      options = [ "uid=0" "gid=0" "dmode=0700" "mode=0600" "norock" ];
    };
  systemd.services.wireguard-config = {
    # ensure copy happens before networkd gets started
    wantedBy = [ "systemd-networkd.service" ];
    before = [ "systemd-networkd.service" ];

    after = [ "run-secrets-wireguard.mount" ];
    requires = [ "run-secrets-wireguard.mount" ];
    description = "Copy wireguard config to correct folder.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeScript "wireguard-config.sh"
        ''
          #!${pkgs.bash}/bin/bash

          set -euo pipefail
          set -x

          DEST_DIR=/etc/systemd/network
          SOURCE_DIR=/run/secrets/wireguard

          mkdir -p "''${DEST_DIR}"

          umask 027
          for file in "''${SOURCE_DIR}/"*; do
            test -f "''${file}" || continue
            dest="''${DEST_DIR}/$(basename "''${file}")"
            cat "$file" > "$dest"
            chown root:systemd-network "$dest"
          done
        '';
    };
  };

  # mount service account secret
  fileSystems."/run/secrets/kubernetes.io/serviceaccount" =
    {
      device = "/dev/disk/by-id/virtio-service-account";
      options = [ "uid=0" "gid=0" "dmode=0700" "mode=0600" "norock" ];
    };

  # setup socks proxy
  services.dante = {
    enable = true;
    config = ''
      # uncomment for more debug logging
      #debug: 1

      # interface specification
      internal: enp1s0 port = 1080
      internal: lo port = 1080
      external: wg-prometheus


      #authentication methods
      clientmethod: none
      socksmethod: none

      # allow all clients to connect from anywhere
      client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: error # connect disconnect
      }

      # allow clients connecting to those networks
      socks pass {
              from: 0.0.0.0/0 to: 172.20.0.0/16
              command: bind connect udpassociate
              proxyprotocol: socks_v5
              log: error # connect disconnect iooperation
      }
      socks pass {
              from: 0.0.0.0/0 to: 172.18.0.0/16
              command: bind connect udpassociate
              proxyprotocol: socks_v5
              log: error # connect disconnect iooperation
      }


      # allow path back
      socks pass {
              from: 172.20.0.0/16 to: 0.0.0.0/0
              command: bindreply udpreply
              proxyprotocol: socks_v5
              log: error # connect disconnect iooperation
      }
      socks pass {
              from: 172.18.0.0/16 to: 0.0.0.0/0
              command: bindreply udpreply
              proxyprotocol: socks_v5
              log: error # connect disconnect iooperation
      }
    '';
  };

  # filter traffic coming in from the VPN
  services.iptables-restore = {
    enable = true;
    rulesV4 = ''
      *filter
      :INPUT ACCEPT [0:0]
      :FORWARD ACCEPT [0:0]
      :OUTPUT ACCEPT [0:0]
      -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -i wg-prometheus -p icmp -m icmp --icmp-type echo-request -j ACCEPT
      -A INPUT -i wg-prometheus -j DROP
      -A FORWARD -i wg-prometheus -j DROP
      COMMIT
    '';
    rulesV6 = ''
      *filter
      :INPUT ACCEPT [0:0]
      :FORWARD ACCEPT [0:0]
      :OUTPUT ACCEPT [0:0]
      -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -i wg-prometheus -j DROP
      -A FORWARD -i wg-prometheus -j DROP
      COMMIT
    '';
  };

  system.stateVersion = "21.05";
}
