{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tplink-switch-exporter";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "tplink-switch-exporter";
    rev = "v${version}";
    hash = "sha256-W6Z6WDn3r19ClVLoSuHQTXx1L1oUF2Jy4XApHGtTvXA=";
  };

  vendorHash = "sha256-fZcUbCyJ9KXig+I7SX8+sKCXUTMDDpI3guJiBwbN/3Q=";

  subPackages = [ "." ];

  meta = with lib; {
    homepage = "https://github.com/simonswine/tplink-switch-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.unix;
  };
}
