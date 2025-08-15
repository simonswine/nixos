{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, zlib
, cmake
, protobuf
}:

rustPlatform.buildRustPackage rec {
  pname = "devfilter";
  version = "git-2025-08-15";

  src = fetchFromGitHub {
    owner = "elastic";
    repo = "devfiler";
    rev = "05067fc8490a781b2a8b4b8cf0e3c36a428f4bd0";
    hash = "sha256-mHz6QPB8d4kz+ky83GFyw5gex9cDanuFloqcI0OxoQw=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-QE7TYQiwCChr4n6xy6KAr5FAErzCuVilFiwmN4siSrE=";

  nativeBuildInputs = [
    pkg-config
    cmake
    protobuf
  ];

  buildInputs = [
    openssl
    zlib
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "devfilter";
  };
}
