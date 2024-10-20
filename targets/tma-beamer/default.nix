{ pkgs, inputs, ... }:
let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQ5dGULRFzfKTZPYk9OG95EL/hvE/F8zqHTUHtXTYIt 2017-ed25519-simon@swine.de"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCh2jwszS843PG/pCib2YGAyx6GdtBllxFlUtoAPXHFtD0cXcM7Ckza+uHTHrNuSIOmFP7f7wSi3ANTBOvuQAB9JWWkQ7nyqzeErFqx9EEutJ7uDrj5V6Bn4f1Gj2KAOo6qH1TQ7zPUm4GTjsLitsN3fAu4NASSuTbBZdtSWYwNjZ/+mG2UR4pXFW599UoKw2Aok5w3WadCGGdj/jMNG5uQ1IhI6gv6z4seMqKvGhgHBwO+ujcxDMWcgMsp1A2nG9dGpLAic7KV9Z3UkzfaDDZwRuvSRazFGhfBqqZV3NcgMYVQ6lZ+x+yUQHIDgY+3OS7VCN32DLzCw9ryC0xf2848g+5EjWWuxwaMJH0qTZUNzKQgSDSBXJP2R9HNOmqhrZqw9GqfUWbpnuo+8l1ssFQWcnM0UmBDdyJ0dJRwnuTt6PObjTug/c2iUBAlB+Lgw+42GJCWjiAK8e52ahG6Xt7FlhMlqSVQLzfei2jfSpzSQ1j//ZNuidPQrDR5kLvcKh2Xn8FmN/eyTxIgMA1a4cybSex4xIDL9FGnjrjF6nwk+4TwgtPHbVl4LCNj1nKmQAbpMgxXpQo2gEUlvjCzJ6WWcYP4vmLLDC7CcIG4zVPpL2X7BpH5EW6B9/TD/2RfHA7qiCoAah3czN5WmIRZbSsCoPF3DSGuk626Ap0hOO9wwQ== 2017-rsa-simon@swine.de"
  ];
in

{

  imports =
    [
      # Ensure we cover the hardware quirks
      # inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ];


  # use networkd
  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;

  environment.systemPackages = with pkgs;
    [
      vim
      git
      wireguard-tools
    ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.root =
    {
      openssh.authorizedKeys.keys = authorizedKeys;
    };


  system.stateVersion = "23.05";
}
