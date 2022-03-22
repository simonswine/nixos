{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      pkgsOverlays = [
        (import ./overlays/kubernetes/default.nix)
        (import ./overlays/containerd/default.nix)
      ];

      pkgsConfig = {
        packageOverrides = pkgs: {
          benchstat = pkgs.callPackage ./pkgs/benchstat { };
          cert-updater = pkgs.callPackage ./pkgs/cert-updater { };
          cloud-init = pkgs.callPackage ./pkgs/cloud-init { };
          docker-machine-driver-hetzner = pkgs.callPackage ./pkgs/docker-machine-driver-hetzner { };
          faillint = pkgs.callPackage ./pkgs/faillint { };
          get-focused-x-screen = pkgs.callPackage ./pkgs/get-focused-x-screen { };
          intel-gpu-exporter = pkgs.callPackage ./pkgs/intel-gpu-exporter { };
          mi-flora-exporter = pkgs.callPackage ./pkgs/mi-flora-exporter { };
          modularise = pkgs.callPackage ./pkgs/modularise { };
          mtv-dl = pkgs.callPackage ./pkgs/mtv-dl { };
          prometheus-node-exporter-restic = pkgs.callPackage ./pkgs/prometheus-node-exporter-restic { };
          prometheus-node-exporter-smartmon = pkgs.callPackage ./pkgs/prometheus-node-exporter-smartmon { };
          prometheus-node-exporter-zfs = pkgs.callPackage ./pkgs/prometheus-node-exporter-zfs { };
          prometheus-snmp-exporter-config = pkgs.callPackage ./pkgs/prometheus-snmp-exporter-config { };
          tickrs = pkgs.callPackage ./pkgs/tickrs { };
          tplink-switch-exporter = pkgs.callPackage ./pkgs/tplink-switch-exporter { };
          tz-cli = pkgs.callPackage ./pkgs/tz-cli { };
          yasdi = pkgs.callPackage ./pkgs/yasdi { };
          yasdi-exporter = pkgs.callPackage ./pkgs/yasdi-exporter { };
        };
      };
      nixosModulesPkgs = {
        # propagate git revision
        system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

        nixpkgs = {
          overlays = pkgsOverlays;
          config = pkgsConfig;
        };
      };

      myNixosModules = nixpkgs.lib.mapAttrs'
        (name: value:
          nixpkgs.lib.nameValuePair
            (nixpkgs.lib.removeSuffix ".nix" name)
            (import (./modules + "/${name}"))
        )
        (nixpkgs.lib.filterAttrs
          (_: entryType: entryType == "regular")
          (builtins.readDir ./modules)
        );

      myHomeManagerModules = nixpkgs.lib.mapAttrs'
        (name: value:
          nixpkgs.lib.nameValuePair
            (nixpkgs.lib.removeSuffix ".nix" name)
            (import (./home-manager/modules + "/${name}"))
        )
        (nixpkgs.lib.filterAttrs
          (_: entryType: entryType == "regular")
          (builtins.readDir ./home-manager/modules)
        );

    in

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import nixpkgs) {
            system = system;
            overlays = pkgsOverlays;
            config = pkgsConfig;
          };

          targets = map (nixpkgs.lib.removeSuffix ".nix") (
            nixpkgs.lib.attrNames (
              nixpkgs.lib.filterAttrs
                (_: entryType: entryType == "regular")
                (builtins.readDir ./targets)
            )
          );

          build-target = target: {
            name = target;

            value = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem {
              system = system;

              modules = nixpkgs.lib.attrValues (myNixosModules) ++ [
                nixosModulesPkgs
                (import (./targets + "/${target}.nix"))
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
        rec {
          docker = {
            gitlab-runnerx = pkgs.callPackage ./docker/gitlab-runner { };
          };

          packages = {
            benchstat = pkgs.benchstat;
            cert-updater = pkgs.cert-updater;
            cloud-init = pkgs.cloud-init;
            containerd = pkgs.containerd;
            docker-machine-driver-hetzner = pkgs.docker-machine-driver-hetzner;
            faillint = pkgs.faillint;
            get-focused-x-screen = pkgs.get-focused-x-screen;
            intel-gpu-exporter = pkgs.intel-gpu-exporter;
            kubernetes-1-21 = pkgs.kubernetes-1-21;
            kubernetes-1-22 = pkgs.kubernetes-1-22;
            kubernetes-1-23 = pkgs.kubernetes-1-23;
            mi-flora-exporter = pkgs.mi-flora-exporter;
            modularise = pkgs.callPackage ./pkgs/modularise { };
            mtv-dl = pkgs.mtv-dl;
            prometheus-node-exporter-restic = pkgs.prometheus-node-exporter-restic;
            prometheus-node-exporter-smartmon = pkgs.prometheus-node-exporter-smartmon;
            prometheus-node-exporter-zfs = pkgs.prometheus-node-exporter-zfs;
            prometheus-snmp-exporter-config = pkgs.prometheus-snmp-exporter-config;
            tickrs = pkgs.tickrs;
            tplink-switch-exporter = pkgs.callPackage ./pkgs/tplink-switch-exporter { };
            tz-cli = pkgs.tz-cli;
            yasdi = pkgs.yasdi;
            yasdi-exporter = pkgs.yasdi-exporter;
          };

          nixosConfigurations = builtins.listToAttrs (
            nixpkgs.lib.flatten (
              map
                (
                  target: [
                    (build-target target)
                  ]
                )
                targets
            )
          );
        }
      ) // {

      nixosModules = myNixosModules;
      homeManagerModules = myHomeManagerModules;
    };
}
