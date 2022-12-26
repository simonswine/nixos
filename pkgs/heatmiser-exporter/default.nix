{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "heatmiser-exporter";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "heatmiser-exporter";
    rev = "v${version}";
    sha256 = "fDKo7U8RN5tYjhUBcPDEZzK14UJDszYKQPI26dIQl2o=";
  };
  vendorSha256 = "YVIDwTDSdg5PkdwLZv0lxPHkb/urpIidfUddkIeG00s=";

  subPackages = [ "." ];

  meta = with lib; {
    homepage = "https://github.com/simonswine/heatmiser-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}

