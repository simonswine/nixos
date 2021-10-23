{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mi-flora-exporter";
  version = "27bc317";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "mi-flora-exporter";
    rev = "${version}";
    sha256 = "rx/0FLNq7gcrOAYF2Lb6pdzTpPck0LOaMHVxt8maVxA=";
  };

  vendorSha256 = "0v2jfsr49np9qrwycvi3ac6q6xp8w6lnd4jibkw7d3dycg57radd";

  subPackages = [ "." ];

  meta = with lib; {
    description = "A prometheus exporter which can read data from Xiaomi MiFlora / HHCC Flower Care devices using Bluetooth.";
    homepage = "https://github.com/xperimental/flowercare-exporter";
    license = licenses.mit;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
