{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-20.09";
    };
  };

  outputs = { self, nixpkgs }:
    let
      pkgsOverlays = [
        (import ./overlays/kubernetes/default.nix)
      ];

      pkgsConfig = {
        packageOverrides = pkgs: {
          cloud-init = pkgs.callPackage ./pkgs/cloud-init { };
          prometheus-node-exporter-smartmon = pkgs.callPackage ./pkgs/prometheus-node-exporter-smartmon { };
          prometheus-node-exporter-zfs = pkgs.callPackage ./pkgs/prometheus-node-exporter-zfs { };
          zrepl = pkgs.callPackage ./pkgs/zrepl { };
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
            (import (./targets + "/${target}/hardware-configuration.nix"))
            (import ./local.nix)
          ];
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

      packages = {
        "x86_64-linux" = {
          cloud-init = pkgs.cloud-init;
          "kubernetes-1-18" = pkgs.kubernetes-1-18;
          "kubernetes-1-19" = pkgs.kubernetes-1-19;
          "kubernetes-1-20" = pkgs.kubernetes-1-20;
          prometheus-node-exporter-smartmon = pkgs.prometheus-node-exporter-smartmon;
          prometheus-node-exporter-zfs = pkgs.prometheus-node-exporter-zfs;
          zrepl = pkgs.zrepl;
        };
      };
    };
}
