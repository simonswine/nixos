{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "jsonnet-language-server";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "jsonnet-language-server";
    rev = "v${version}";
    sha256 = "hI8eGfHC7la52nImg6BaBxdl9oD/J9q3F3+xbsHrn30=";
  };
  vendorSha256 = "UEQogVVlTVnSRSHH2koyYaR9l50Rn3075opieK5Fu7I=";

  meta = with lib; {
    description = "A Language Server Protocol server for Jsonnet";
    homepage = "https://github.com/grafana/jsonnet-language-server";
    license = licenses.agpl3;
    maintainers = with maintainers; [ jdbaldry simonswine ];
  };
}
