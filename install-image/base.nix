{ config, inputs, ... }: {
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  services.openssh.enable = true;
  users.extraUsers.root.openssh.authorizedKeys.keys = config.swine.ssh.pubkeys.simonswine;
  system.stateVersion = "24.05";
}
