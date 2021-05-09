{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "flowercare-exporter";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "xperimental";
    repo = "flowercare-exporter";
    rev = "v${version}";
    sha256 = "172ycvvzyklj5pp2js7dwhlvicp278sqrzg0zhjc77jzhizzhynk";
  };

  vendorSha256 = "0032y82q1h8am8d6v8hvq4g2cmi16y5925kh0p92is9s3i2ljsiz";

  subPackages = [ "." ];

  meta = with lib; {
    description = "A prometheus exporter which can read data from Xiaomi MiFlora / HHCC Flower Care devices using Bluetooth.";
    homepage = "https://github.com/xperimental/flowercare-exporter";
    license = licenses.mit;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
