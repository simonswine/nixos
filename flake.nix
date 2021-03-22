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
        };
      };

      pkgs = (import nixpkgs) {
        system = "x86_64-linux";
        overlays = pkgsOverlays;
        config = pkgsConfig;
      };

      nixosModulesPkgs = {
        nixpkgs = {
          overlays = pkgsOverlays;
          config = pkgsConfig;
        };
      };

      myNixosModules = [
        ./modules/containerd.nix
        ./modules/kubernetes-kubelet-kubeadm.nix
      ];

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

          modules = myNixosModules ++ [
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

      packages = {
        "x86_64-linux" = {
          cloud-init = pkgs.cloud-init;
          "kubernetes-1-18" = pkgs.kubernetes-1-18;
          "kubernetes-1-19" = pkgs.kubernetes-1-19;
          "kubernetes-1-20" = pkgs.kubernetes-1-20;
        };
      };
    };
}
