# This has been mostly adapted from: https://github.com/nix-community/docker-nixpkgs/blob/8fdb8770b3a574ce644f3f0e6a0cedb527944793/images/nix/default.nix
{ cacert
, bashInteractive
, coreutils
, dockerTools
, gnugrep
, gnumake
, nix
, iana-etc
, gitMinimal
, gnutar
, gzip
, openssh
, xz
, writeTextFile
, attic-client
}:
dockerTools.buildImage
{
  name = "simonswine/gitlab-runner-nix";
  tag = "nixos-25.05";
  created = "now";

  contents = [
    ./root
    coreutils
    # add /bin/sh
    bashInteractive
    nix

    # runtime dependencies of nix
    cacert
    gitMinimal
    gnutar
    gzip
    openssh
    xz
    gnumake
    gnugrep

    attic-client

    # for haskell binaries
    iana-etc

    # enable flakes
    (writeTextFile {
      name = "nix.conf";
      destination = "/etc/nix/nix.conf";
      text = ''
        accept-flake-config = true
        experimental-features = nix-command flakes
      '';
    })

  ];

  extraCommands = ''
    # for /usr/bin/env
    mkdir usr
    ln -s ../bin usr/bin

    # make sure /tmp exists
    mkdir -m 1777 tmp

    # need a HOME
    mkdir -vp root
  '';

  config = {
    Entrypoint = [ "/bin/bash" "-l" "-c" ];
    Cmd = "/bin/bash";
    Env = [
      "ENV=/etc/profile.d/nix.sh"
      "BASH_ENV=/etc/profile.d/nix.sh"
      "NIX_BUILD_SHELL=/bin/bash"
      "NIX_PATH=nixpkgs=${./fake_nixpkgs}"
      "PAGER=cat"
      "PATH=/root/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      "USER=root"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}


