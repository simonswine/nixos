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
  version = "git-2026-02-18";

  src = fetchFromGitHub {
    owner = "elastic";
    repo = "devfiler";
    rev = "649d48acbb69b04dc6565a6d0ae1e5d29c4e5555";
    hash = "sha256-SD9kZnBUBpxH1E1ugAPYDq7HRMsyBHuQPM7nnMUKNVw=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-3ZGYcpj2ME8Wd9DXiYlcCu9bNoi2Cbu1zkhw/U/9tqM=";

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
