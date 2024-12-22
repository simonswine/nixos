{
  inputs = {
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11-small";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = { self, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;

      pkgsOverlays = [
        inputs.poetry2nix.overlays.default
        (import ./overlays/kubernetes/default.nix)
        (import ./overlays/containerd/default.nix)
        (import ./overlays/cloud-init/default.nix)
      ];

      pkgsConfig = {
        packageOverrides = pkgs: {
          austin = pkgs.callPackage ./pkgs/austin { };
          benchstat = pkgs.callPackage ./pkgs/benchstat { };
          cert-updater = pkgs.callPackage ./pkgs/cert-updater { };
          dezoomify-rs = pkgs.callPackage ./pkgs/dezoomify-rs { };
          dhclient = pkgs.callPackage ./pkgs/dhclient { };
          docker-machine = pkgs.callPackage ./pkgs/docker-machine { };
          docker-machine-driver-hetzner = pkgs.callPackage ./pkgs/docker-machine-driver-hetzner { };
          faillint = pkgs.callPackage ./pkgs/faillint { };
          get-focused-x-screen = pkgs.callPackage ./pkgs/get-focused-x-screen { };
          gimli-addr2line = pkgs.callPackage ./pkgs/gimli-addr2line { };
          goda = pkgs.callPackage ./pkgs/goda { };
          growatt-proxy-exporter = pkgs.callPackage ./pkgs/growatt-proxy-exporter { };
          heatmiser-exporter = pkgs.callPackage ./pkgs/heatmiser-exporter { };
          intel-gpu-exporter = pkgs.callPackage ./pkgs/intel-gpu-exporter { };
          jsonnet-language-server = pkgs.callPackage ./pkgs/jsonnet-language-server { };
          miio = pkgs.callPackage ./pkgs/python-miio { };
          mi-flora-exporter = pkgs.callPackage ./pkgs/mi-flora-exporter { };
          modularise = pkgs.callPackage ./pkgs/modularise { };
          mtv-dl = pkgs.callPackage ./pkgs/mtv-dl { };
          g810-led = pkgs.callPackage ./pkgs/g810-led { };
          nut-exporter = pkgs.callPackage ./pkgs/nut-exporter { };
          orangepi-firmware = pkgs.callPackage ./pkgs/orangepi-firmware { };
          phpspy = pkgs.callPackage ./pkgs/phpspy { };
          prometheus-node-exporter-restic = pkgs.callPackage ./pkgs/prometheus-node-exporter-restic { };
          prometheus-node-exporter-smartmon = pkgs.callPackage ./pkgs/prometheus-node-exporter-smartmon { };
          prometheus-node-exporter-zfs = pkgs.callPackage ./pkgs/prometheus-node-exporter-zfs { };
          prometheus-snmp-exporter-config = pkgs.callPackage ./pkgs/prometheus-snmp-exporter-config { };
          pyroscope = pkgs.callPackage ./pkgs/pyroscope { };
          profilecli = pkgs.callPackage ./pkgs/profilecli { };
          sleepwatcher = pkgs.callPackage ./pkgs/sleepwatcher { };
          tplink-switch-exporter = pkgs.callPackage ./pkgs/tplink-switch-exporter { };
          tz-cli = pkgs.callPackage ./pkgs/tz-cli { };
          vim-markdown-composer = pkgs.callPackage ./pkgs/vim-markdown-composer { };
          yasdi = pkgs.callPackage ./pkgs/yasdi { };
          yasdi-exporter = pkgs.callPackage ./pkgs/yasdi-exporter { };
        };
      };
      nixosModulesPkgs = {
        nixpkgs = {
          overlays = pkgsOverlays;
          config = pkgsConfig;
        };
      };

      myNixosModules = lib.mapAttrs'
        (name: value:
          lib.nameValuePair
            (lib.removeSuffix ".nix" name)
            (import (./modules + "/${name}"))
        )
        (lib.filterAttrs
          (_: entryType: entryType == "regular")
          (builtins.readDir ./modules)
        );

      myHomeManagerModules = lib.mapAttrs'
        (name: value:
          lib.nameValuePair
            (lib.removeSuffix ".nix" name)
            (import (./home-manager/modules + "/${name}"))
        )
        (lib.filterAttrs
          (_: entryType: entryType == "regular")
          (builtins.readDir ./home-manager/modules)
        );

      targets =
        lib.attrNames (
          lib.filterAttrs
            (_: entryType: entryType == "directory")
            (builtins.readDir ./targets)
        );

      build-target = target: system: {
        name = target;
        value = lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs; };
          modules = lib.attrValues myNixosModules ++ [
            nixosModulesPkgs
            (import (./targets + "/${target}/default.nix"))
            (import ./local.nix)
          ] ++ (
            let
              path = ./targets + "/${target}/hardware-configuration.nix";
            in
            if builtins.pathExists path then [ (import path) ] else [ ]
          );
        };
      };

    in
    inputs.flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import inputs.nixpkgs) {
            system = system;
            overlays = pkgsOverlays;
            config = pkgsConfig;
          };
        in
        {

          docker = {
            gitlab-runner = pkgs.callPackage ./docker/gitlab-runner { };
          };

          packages = {
            hcloud-kexec = inputs.nixos-generators.nixosGenerate {
              system = system;
              modules = [
                ./targets/hcloud-kexec.nix
                ./targets/hcloud-kexec/hardware-configuration.nix
              ];
              format = "kexec-bundle";
            };

            austin = pkgs.austin;
            benchstat = pkgs.benchstat;
            cert-updater = pkgs.cert-updater;
            cloud-init = pkgs.cloud-init;
            containerd = pkgs.containerd;
            dezoomify-rs = pkgs.dezoomify-rs;
            dhclient = pkgs.dhclient;
            docker-machine = pkgs.docker-machine;
            docker-machine-driver-hetzner = pkgs.docker-machine-driver-hetzner;
            faillint = pkgs.faillint;
            g810-led = pkgs.g810-led;
            get-focused-x-screen = pkgs.get-focused-x-screen;
            gimli-addr2line = pkgs.gimli-addr2line;
            goda = pkgs.goda;
            growatt-proxy-exporter = pkgs.growatt-proxy-exporter;
            heatmiser-exporter = pkgs.heatmiser-exporter;
            intel-gpu-exporter = pkgs.intel-gpu-exporter;
            jsonnet-language-server = pkgs.jsonnet-language-server;
            kubernetes-1-28 = pkgs.kubernetes-1-28;
            kubernetes-1-29 = pkgs.kubernetes-1-29;
            kubernetes-1-30 = pkgs.kubernetes-1-30;
            kubernetes-1-31 = pkgs.kubernetes-1-31;
            miio = pkgs.miio;
            mi-flora-exporter = pkgs.mi-flora-exporter;
            modularise = pkgs.modularise;
            mtv-dl = pkgs.mtv-dl;
            nut-exporter = pkgs.nut-exporter;
            orangepi-firmware = pkgs.orangepi-firmware;
            phpspy = pkgs.phpspy;
            prometheus-node-exporter-restic = pkgs.prometheus-node-exporter-restic;
            prometheus-node-exporter-smartmon = pkgs.prometheus-node-exporter-smartmon;
            prometheus-node-exporter-zfs = pkgs.prometheus-node-exporter-zfs;
            prometheus-snmp-exporter-config = pkgs.prometheus-snmp-exporter-config;
            pyroscope = pkgs.pyroscope;
            profilecli = pkgs.profilecli;
            sleepwatcher = pkgs.callPackage ./pkgs/sleepwatcher { };
            tplink-switch-exporter = pkgs.callPackage ./pkgs/tplink-switch-exporter { };
            tz-cli = pkgs.tz-cli;
            vim-markdown-composer = pkgs.vim-markdown-composer;
            yasdi = pkgs.yasdi;
            yasdi-exporter = pkgs.yasdi-exporter;

          };

        }
      ) // {

      nixosConfigurations =
        let

          targetsBySystem = {
            armv6l-linux = [
              "install-image-rpi2"
            ];
            aarch64-linux = [
              "install-image-aarch64-linux"
              "install-image-orangepi5plus"
              "install-image-rockpi4b"
              "tma-client"
              "tma-beamer"
              "tma-orangepi5plus"
              "tma-rockpi4b"
            ];
          };

          systemForTarget = target:
            builtins.foldl'
              (a: b: if builtins.elem target b.value then b.name else a)
              "x86_64-linux"
              (lib.attrsToList targetsBySystem);
        in
        builtins.listToAttrs (
          lib.flatten (
            map
              (
                target: [
                  (build-target target (systemForTarget target))
                ]
              )
              targets
          )
        );

      hardware = {
        orangepi5plus = ./hardware/orangepi5plus/default.nix;
      };

      installImages = {
        aarch64-linux = self.nixosConfigurations.install-image-aarch64-linux.config.system.build.sdImage;
        orangepi5plus = self.nixosConfigurations.install-image-orangepi5plus.config.system.build.sdImage;
        rockpi4b = self.nixosConfigurations.install-image-rockpi4b.config.system.build.sdImage;
        rpi2 = self.nixosConfigurations.install-image-rpi2.config.system.build.sdImage;
      };

      nixosModules = myNixosModules;
      homeManagerModules = myHomeManagerModules;
    };
}
