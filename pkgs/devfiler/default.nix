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
  version = "git-2025-09-22";

  src = fetchFromGitHub {
    owner = "elastic";
    repo = "devfiler";
    rev = "ae6ec150adf10c0f2e8cc5e32556f62df0092917";
    hash = "sha256-1sLu9WNK/dzbvuKFYjAeYwnD8nSiGrVRlQWUgOngFpo=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-EGBkbxqeKcXxKxdcZ9OO3ERaryaK+tkJrWeXKjf7Gro=";

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
    mainProgram = "devfiler";
  };
}
