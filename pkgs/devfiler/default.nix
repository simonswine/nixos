{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, zlib
, cmake
, protobuf
, llvmPackages
}:

rustPlatform.buildRustPackage {
  pname = "devfiler";
  version = "git-2025-10-01";

  src = fetchFromGitHub {
    owner = "elastic";
    repo = "devfiler";
    rev = "4b20b5ee634e4b5c58016658957260a73b16800b";
    hash = "sha256-7GvXkAIvtpYbhfpEc6A7i/6gdB8uHMKTlWi9man+aE8=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-EGBkbxqeKcXxKxdcZ9OO3ERaryaK+tkJrWeXKjf7Gro=";

  nativeBuildInputs = [
    pkg-config
    cmake
    protobuf
    rustPlatform.bindgenHook
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
