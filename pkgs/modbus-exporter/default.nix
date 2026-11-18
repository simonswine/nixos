{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "modbus-exporter";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "RichiH";
    repo = "modbus_exporter";
    rev = "v${version}";
    hash = "sha256-QUFYdu8f8OfYCYy4qQ+WIwHpZDIbtOv3CFLGFRraeU0=";
  };

  vendorHash = "sha256-qIxlqWxUIG6QFAUGWcUQntWPeX7AGaJ7KszcSa/j8MA=";

  subPackages = [ "." ];

  postInstall = ''
    mv $out/bin/modbus_exporter $out/bin/modbus-exporter
  '';

  meta = with lib; {
    homepage = "https://github.com/simonswine/modbus-exporter";
    license = licenses.asl20;
    maintainers = lib.optional (lib.maintainers ? simonswine) lib.maintainers.simonswine;
    platforms = platforms.unix;
  };
}
