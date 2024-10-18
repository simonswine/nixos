# Export public keys for certain users

{ config, lib, ... }:

with lib;
let
  cfg = config.swine.ssh.pubkeys;
in
{
  options.swine.ssh.pubkeys = mkOption {
    default = {
      simonswine = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQ5dGULRFzfKTZPYk9OG95EL/hvE/F8zqHTUHtXTYIt 2017-ed25519-simon@swine.de"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCh2jwszS843PG/pCib2YGAyx6GdtBllxFlUtoAPXHFtD0cXcM7Ckza+uHTHrNuSIOmFP7f7wSi3ANTBOvuQAB9JWWkQ7nyqzeErFqx9EEutJ7uDrj5V6Bn4f1Gj2KAOo6qH1TQ7zPUm4GTjsLitsN3fAu4NASSuTbBZdtSWYwNjZ/+mG2UR4pXFW599UoKw2Aok5w3WadCGGdj/jMNG5uQ1IhI6gv6z4seMqKvGhgHBwO+ujcxDMWcgMsp1A2nG9dGpLAic7KV9Z3UkzfaDDZwRuvSRazFGhfBqqZV3NcgMYVQ6lZ+x+yUQHIDgY+3OS7VCN32DLzCw9ryC0xf2848g+5EjWWuxwaMJH0qTZUNzKQgSDSBXJP2R9HNOmqhrZqw9GqfUWbpnuo+8l1ssFQWcnM0UmBDdyJ0dJRwnuTt6PObjTug/c2iUBAlB+Lgw+42GJCWjiAK8e52ahG6Xt7FlhMlqSVQLzfei2jfSpzSQ1j//ZNuidPQrDR5kLvcKh2Xn8FmN/eyTxIgMA1a4cybSex4xIDL9FGnjrjF6nwk+4TwgtPHbVl4LCNj1nKmQAbpMgxXpQo2gEUlvjCzJ6WWcYP4vmLLDC7CcIG4zVPpL2X7BpH5EW6B9/TD/2RfHA7qiCoAah3czN5WmIRZbSsCoPF3DSGuk626Ap0hOO9wwQ== 2017-rsa-simon@swine.de"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILz03jgLU+UuLX8Ujx+wwMKcuKgttlUa2QdvaSi1m0VR christian@christian-x1"
      ];
      benedikt = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDl8AVoqLUYze+g9bSnzmhrHcxbACDF0STbNDgRLfo0/WRicyemNSNaYb7I1sLggrrkQbtiHoceGXEQJYQToNhky4urTliY/8GlAP85Zr14fbcNDPNyUoEpf41BOLUfG5VAHo1Eqv0EvMeqQOvmm75B3eRAmZ/Jdf3E2Z9rPmyOAZqRuldmr126khq/cl7miLn3IN9JXjDrZ2MkqWUc8k/p/j/etvqmVTxo1GjY6d66/wCrBtv7opVhlGpOgMAbtTs1OvDGeTFnBkZPrlW2nJULGHxmGatpMuYQp4sPtNTaVoNiuG5zvbyIGgSjj/MwedD3HVmj7o4jHyJPrP9q9vuzX5/CgiixezP8dx+TogOxoaQuwSF2Yp1CGPn+6f9s5/XArZdvQFwpRx+ycShLwvItwDgmJhBEi2FOoVmGuSuo4ONXGvVlWOLVeCv/A8ub2aYvDyYLraZyv3qoBZuz9ErRA1N9Ce0im9dvp88WIzY75JCGWTL8hgKlHWUf2zjU4Ko4SgaIv7861yThc8u7JBIJcLA0+b48intaIjtRsNrYmkYbNbvDVaxhiLe8wxNRiL04Ttjnwrp/Rh8TkSrNL/lZJhbsoH4B0ZdRVJsJg26ZUr1FooqZUyt8NDtBG0vQA25xp1VvFwWHJEBgwyeO/DEuG/Avc4Tqr31DNepZKK+dHQ== bs@debian"
      ];
    };
  };
}
