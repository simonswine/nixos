{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "pyroscope";
  version = "1.7.0-pre";
  revision = "4ff5438";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "pyroscope";
    rev = revision;
    hash = "sha256-cf54X+6NZd8EVIB6m9Ng8SsDZVYGDdSQf+B0oW4Qsm8=";
  };

  vendorHash = "sha256-ggntpnU9s2rpkv6S0LnZNexrdkBsdsUrGPc93SVrK4M=";

  preBuild = ''
    export GOWORK=off
  '';

  ldflags =
    let
      prefix = "github.com/grafana/pyroscope/pkg/util/build";
    in
    [
      "-X ${prefix}.Version=${version}"
      "-X ${prefix}.Branch=HEAD"
      "-X ${prefix}.Revision=${revision}"
    ];

  subPackages = [
    "cmd/pyroscope"
    "cmd/profilecli"
  ];

  meta = with lib; {
    description = "Continuous Profiling Platform. Debug performance issues down to a single line of code";
    homepage = "https://grafana.com/oss/pyroscope";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ simonswine ];
  };
}
