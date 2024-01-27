{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "growatt-proxy-exporter";
  version = "49daba34f27c02d75afc8a0575158be8910ddba4";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "growatt-proxy-exporter";
    rev = "${version}";
    sha256 = "V3FeweVL3ilax5y9N/hPlbRO5fU6mLtYCYWtQIKTcKc=";
  };

  vendorHash = "sha256-fZtPxIrwFGdSx6iH+OOFpkOwqb2Uoglo0T11/TJ+VpM=";

  ldflags = [ "-X main.Version=${version}" ];

  doCheck = false;

  subPackages = [ "." ];

  meta = with lib; {
    description = "A Prometheus exporter mitm growatt inverter measurement.";
    homepage = "https://github.com/simonswine/growatt-proxy-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
