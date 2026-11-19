{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "nut-exporter";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "DRuggeri";
    repo = "nut_exporter";
    rev = "v${version}";
    sha256 = "sha256-ZbX5gHQhIVFzxMlx4xZYaEHLuiMNvTmJ5puAjC2rgfw=";
  };

  vendorHash = "sha256-tqlsqAgZzFOhyQkikHAWr/NyOGFDW6yh2iiK0zuyUbU=";

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
    maintainers = lib.optional (lib.maintainers ? simonswine) lib.maintainers.simonswine;
    platforms = platforms.linux;
  };
}
