{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mi-flora-exporter";
  version = "27bc317";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "mi-flora-exporter";
    rev = "${version}";
    hash = "sha256-rx/0FLNq7gcrOAYF2Lb6pdzTpPck0LOaMHVxt8maVxA=";
  };

  vendorHash = "sha256-ral8ymO+jXb4XFGSZqnh6HaDDVMjbuZ5xunaRLJ2Umw=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "A prometheus exporter which can read data from Xiaomi MiFlora / HHCC Flower Care devices using Bluetooth.";
    homepage = "https://github.com/xperimental/flowercare-exporter";
    license = licenses.mit;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
