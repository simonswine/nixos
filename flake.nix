{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-21.11";
    };
  };

  outputs = { self, nixpkgs }:
    let
      pkgsOverlays = [
        (import ./overlays/kubernetes/default.nix)
        (import ./overlays/containerd/default.nix)
      ];

      pkgsConfig = {
        packageOverrides = pkgs: {
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
        };
      };

      pkgs = (import nixpkgs) {
        system = "x86_64-linux";
        overlays = pkgsOverlays;
        config = pkgsConfig;
      };

      nixosModulesPkgs = {
        # propagate git revision
        system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

        nixpkgs = {
          overlays = pkgsOverlays;
          config = pkgsConfig;
        };
      };

      myNixosModules = pkgs.lib.mapAttrs'
        (name: value:
          pkgs.lib.nameValuePair
            (pkgs.lib.removeSuffix ".nix" name)
            (import (./modules + "/${name}"))
        )
        (pkgs.lib.filterAttrs
          (_: entryType: entryType == "regular")
          (builtins.readDir ./modules)
        );

      myHomeManagerModules = pkgs.lib.mapAttrs'
        (name: value:
          pkgs.lib.nameValuePair
            (pkgs.lib.removeSuffix ".nix" name)
            (import (./home-manager/modules + "/${name}"))
        )
        (pkgs.lib.filterAttrs
          (_: entryType: entryType == "regular")
          (builtins.readDir ./home-manager/modules)
        );

      targets = map (pkgs.lib.removeSuffix ".nix") (
        pkgs.lib.attrNames (
          pkgs.lib.filterAttrs
            (_: entryType: entryType == "regular")
            (builtins.readDir ./targets)
        )
      );

      build-target = target: {
        name = target;

        value = pkgs.lib.makeOverridable nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = pkgs.lib.attrValues (myNixosModules) ++ [
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
    {
      nixosConfigurations = builtins.listToAttrs (
        pkgs.lib.flatten (
          map
            (
              target: [
                (build-target target)
              ]
            )
            targets
        )
      );

      nixosModules = myNixosModules;

      homeManagerModules = myHomeManagerModules;

      packages = {
        "x86_64-linux" = {
          docker = {
            gitlab-runner = pkgs.callPackage ./docker/gitlab-runner { };
          };
          cert-updater = pkgs.cert-updater;
          cloud-init = pkgs.cloud-init;
          containerd = pkgs.containerd;
          docker-machine-driver-hetzner = pkgs.docker-machine-driver-hetzner;
          faillint = pkgs.faillint;
          get-focused-x-screen = pkgs.get-focused-x-screen;
          intel-gpu-exporter = pkgs.intel-gpu-exporter;
          kubernetes-1-20 = pkgs.kubernetes-1-20;
          kubernetes-1-21 = pkgs.kubernetes-1-21;
          kubernetes-1-22 = pkgs.kubernetes-1-22;
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
        };
      };
    };
}
