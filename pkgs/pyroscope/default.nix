{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "pyroscope";
  version = "2.0.1";
  revision = "4ff5438";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "pyroscope";
    rev = "v${version}";
    hash = "sha256-+2L8C2OaRkZ6BWQtdo6bHUhZBskoJ7toHT5C6WPFWwg=";
  };

  vendorHash = "sha256-y/uOOz4rDCgrNnpyzSBIovHcTtXiMI2pGxeoo6A/9yE=";

  preBuild = ''
    export GOWORK=off
  '';

  ldflags =
    let
      prefix = "github.com/grafana/pyroscope/v2/pkg/util/build";
    in
    [
      "-X ${prefix}.Version=${version}"
      "-X ${prefix}.Branch=HEAD"
      "-X ${prefix}.Revision=${revision}"
    ];

  doCheck = false; # yolo

  subPackages = [
    "cmd/pyroscope"
    "cmd/profilecli"
  ];

  meta = with lib; {
    description = "Continuous Profiling Platform. Debug performance issues down to a single line of code";
    homepage = "https://grafana.com/oss/pyroscope";
    license = licenses.agpl3Only;
  };
}
