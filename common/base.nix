{ inputs, pkgs, ... }:
{

  # Export sys as a local registry
  nix.registry.sys = {
    from = {
      type = "indirect";
      id = "sys";
    };
    flake = inputs.nixpkgs;
  };

  environment.systemPackages = [
    pkgs.git
    pkgs.vim
  ];

  # Use flakes version for nix-shell/nix-env
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
