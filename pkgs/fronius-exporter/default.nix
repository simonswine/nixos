{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "fronius-exporter";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "fronius-exporter";
    rev = "v${version}";
    hash = "sha256-ArWdH2G3e1XWZQ4XHJRI/o/sNdLQ/55uV6gARi/naHw=";
  };

  vendorHash = "sha256-PKdn+AhW9wIBgBN5uwtU41SgK1kD9d+B59cKPP7BGcs=";

  subPackages = [ "." ];

  meta = with lib; {
    homepage = "https://github.com/simonswine/fronius-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.unix;
  };
}
