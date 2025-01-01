{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "modbus-exporter";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "RichiH";
    repo = "modbus_exporter";
    rev = "v${version}";
    hash = "sha256-ZkES+CDthYZrNZ7wVO0oRx6pBMX23AyUOhU+OBTD42g=";
  };

  vendorHash = "sha256-RfpJLoYPR5Ura3GvLIAePg+fuiaiXig6XaSNCPhZ/Vg=";

  subPackages = [ "." ];

  postInstall = ''
    mv $out/bin/modbus_exporter $out/bin/modbus-exporter
  '';

  meta = with lib; {
    homepage = "https://github.com/simonswine/modbus-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.unix;
  };
}

