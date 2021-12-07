{ config, pkgs, lib, ... }:

let
  preBuildScript = pkgs.writeScript "setup-container" ''
    mkdir -p -m 0755 /nix/var/log/nix/drvs
    mkdir -p -m 0755 /nix/var/nix/gcroots
    mkdir -p -m 0755 /nix/var/nix/profiles
    mkdir -p -m 0755 /nix/var/nix/temproots
    mkdir -p -m 0755 /nix/var/nix/userpool
    mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
    mkdir -p -m 1777 /nix/var/nix/profiles/per-user
    mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
    mkdir -p -m 0700 "$HOME/.nix-defexpr"
    . ${pkgs.nix}/etc/profile.d/nix.sh
    ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-21.11 nixpkgs
    ${pkgs.nix}/bin/nix-channel --update nixpkgs
    ${pkgs.nix}/bin/nix-env -i ${builtins.concatStringsSep " " (with pkgs; [ nixFlakes cacert git openssh ])}
  '';
in

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "deadcafe";
  cloud.provider = "hcloud";

  # Install nix flakes to allow modifications
  programs.nixflakes.enable = true;

  # Setup cache
  nix = {
    binaryCaches = [
      "https://nixos.cachix.swine.de"
    ];
    binaryCachePublicKeys = [
      "nixos.cachix.swine.de-1:wXwJAbrysI3qC2yJpbATTHfQ5QmqvbOabmQ6m9V9auk="
    ];
  };

  # make /etc/hosts writeable, required by docker-machine provisioning
  environment.etc.hosts.mode = "0644";

  # allow access to encrypted docker port
  networking.firewall.allowedTCPPorts = [ 2376 ];

  # make docker-machine to detect a centos 8
  environment.etc.os-release.text = lib.mkForce ''
    NAME="CentOS Linux"
    VERSION="8 (Core)"
    ID="centos"
    ID_LIKE="rhel fedora"
    VERSION_ID="8"
    PRETTY_NAME="CentOS Linux 8 (Core)"
    ANSI_COLOR="0;31"
    CPE_NAME="cpe:/o:centos:centos:8"
    HOME_URL="https://www.centos.org/"
    BUG_REPORT_URL="https://bugs.centos.org/"

    CENTOS_MANTISBT_PROJECT="CentOS-8"
    CENTOS_MANTISBT_PROJECT_VERSION="8"
    REDHAT_SUPPORT_PRODUCT="centos"
    REDHAT_SUPPORT_PRODUCT_VERSION="8"
  '';

  environment.variables = {
    PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
  };

  environment.systemPackages = with pkgs;
    [
      vim
      git
      cachix
      # Provide a fake yum, so docker-machine is happy
      (pkgs.writeShellScriptBin "yum" "exit 0")

      # Allow docker-machine to "write" to the override of docker.service.d
      (pkgs.writeShellScriptBin "tee" ''
        if [ "$1" = "/etc/systemd/system/docker.service.d/10-machine.conf" ]; then
          # Take the ExecStart line
          EXTRA_ARGS=`cat /dev/stdin | grep -P -o '^ExecStart=/usr/bin/dockerd \K(.*)'`

          # Remove unwanted flags
          EXTRA_ARGS=''${EXTRA_ARGS/-H unix:\/\/\/var\/run\/docker.sock /}
          EXTRA_ARGS=''${EXTRA_ARGS/--storage-driver overlay2 /}

          # Write to file
          mkdir -p /run/sysconfig
          echo "EXTRA_ARGS=\"''${EXTRA_ARGS}\"" | ${pkgs.coreutils}/bin/tee "/run/sysconfig/docker"
          exit 0
        fi
        exec ${pkgs.coreutils}/bin/tee "$@"
      '')

    ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  boot.kernel.sysctl."net.ipv4.ip_forward" = true; # 1
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    extraOptions = "$EXTRA_ARGS";
  };
  # Read the docker-machine flags from runtime file
  systemd.services.docker = {
    serviceConfig = {
      EnvironmentFile = "-/run/sysconfig/docker";
    };
  };

  system.activationScripts.gitlab-runner-nix.text =
    ''
      mkdir -p /nix/init
      cat ${preBuildScript} > /nix/init/activate
    '';

  system.stateVersion = "21.05";
}
