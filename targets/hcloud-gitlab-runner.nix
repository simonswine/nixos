{ config, pkgs, lib, ... }:

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

  environment.systemPackages = with pkgs;
    [
      vim
      git
      cachix
    ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  boot.kernel.sysctl."net.ipv4.ip_forward" = true; # 1
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };

  services.gitlab-runner = {
    enable = true;
    services = {
      # runner for building in docker via host's nix-daemon
      # nix store will be readable in runner, might be insecure
      nix = with lib; {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = "/etc/gitlab-runner/env";
        dockerImage = "alpine";
        dockerVolumes = [
          "/nix/store:/nix/store:ro"
          "/nix/var/nix/db:/nix/var/nix/db:ro"
          "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        ];
        dockerDisableCache = true;
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
          ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-21.05 nixpkgs # 3
          ${pkgs.nix}/bin/nix-channel --update nixpkgs
          ${pkgs.nix}/bin/nix-env -i ${concatStringsSep " " (with pkgs; [ nixFlakes cacert git openssh ])}
        '';
        environmentVariables = {
          ENV = "/etc/profile";
          USER = "root";
          NIX_REMOTE = "daemon";
          PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
          NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
        };
        tagList = [ "nix" ];
      };
    };
  };


  system.stateVersion = "21.05";
}
