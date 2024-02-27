{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "pyroscope";
  version = "1.4.0";
  revision = "f8e6d8b01";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "pyroscope";
    rev = "v${version}";
    hash = "sha256-/x7X84snzN2orldKV1th5HJmw2iLlsaav61quP44R6k=";
  };

  vendorHash = "sha256-+B96m6coa1AEO7ss2i7+dWIJG1cHZQI4ZEDx7O6jZUo=";

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

  subPackages = [ "cmd/pyroscope" "cmd/profilecli" ];

  meta = with lib; {
    description = "Continuous Profiling Platform. Debug performance issues down to a single line of code";
    homepage = "https://grafana.com/oss/pyroscope";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ simonswine ];
  };
}
