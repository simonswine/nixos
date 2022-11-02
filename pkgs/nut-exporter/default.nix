{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nut-exporter";
  version = "v2.4.2";

  src = fetchFromGitHub {
    owner = "DRuggeri";
    repo = "nut_exporter";
    rev = "${version}";
    sha256 = "fymVx6FJGII2PmWXVfeCRTxfO+35bmyn/9iL0iPuBgo=";
  };

  vendorSha256 = "ji8JlEYChPBakt5y6+zcm1l04VzZ0/fjfGFJ9p+1KHE=";

  postInstall = ''
    mv $out/bin/nut_exporter $out/bin/nut-exporter
  '';

  ldflags = [ "-X main.Version=${version}" ];

  doCheck = false;

  subPackages = [ "." ];

  meta = with lib; {
    description = "A Prometheus exporter for the Network UPS Tools server.";
    homepage = "https://github.com/DRuggeri/nut_exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
