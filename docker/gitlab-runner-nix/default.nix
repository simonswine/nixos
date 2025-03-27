{ cacert
, bashInteractive
, coreutils
, dockerTools
, gnugrep
, gnumake
}:
dockerTools.buildLayeredImage
{
  name = "simonswine/gitlab-runner-nix";
  tag = "nixos-24.05";
  created = "now";
  contents = [
    bashInteractive # required for Gitlab Runner
    coreutils # required for Gitlab Runner
    gnugrep # GitLab pipelines otherwise show an error
    gnumake
  ];
  config = {
    Env = [
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
