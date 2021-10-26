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
      password = "nixos";
    };

  # mount wireguard config
  fileSystems."/run/secrets/wireguard" =
    {
      device = "/dev/disk/by-id/virtio-wireguard-config";
      options = [ "uid=0" "gid=0" "dmode=0700" "mode=0600" "norock" ];
    };
  systemd.services.wireguard-config = {
    wantedBy = [ "multi-user.target" ];
    after = [ "run-secrets-wireguard.mount" ];
    requires = [ "run-secrets-wireguard.mount" ];
    before = [ "network.target" ];
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

  system.stateVersion = "21.05";
}
