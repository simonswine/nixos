{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mi-flora-exporter";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "mi-flora-exporter";
    rev = "v${version}";
    sha256 = "0v1vaxarp6zcljzrzx9nidj2w9gnhf7kdfyys5kywpx34dk26pbf";
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
