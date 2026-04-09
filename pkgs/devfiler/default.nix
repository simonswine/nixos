{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zlib,
  cmake,
  protobuf,
  llvmPackages,
}:

rustPlatform.buildRustPackage {
  pname = "devfiler";
  version = "0-unstable-2026-03-30";

  src = fetchFromGitHub {
    owner = "elastic";
    repo = "devfiler";
    rev = "681c08d5a5f840c075e6c5f3e59d92e41bd49214";
    hash = "sha256-EODY7zXegZPx9DawTFsrCChDcLF7uPSoHfb7B+3XDP0=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-41Ay9nNALfTQEe8R2enaVlMD00PI3hRwEGIb5X7KzGM=";

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
