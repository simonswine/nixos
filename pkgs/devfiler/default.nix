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
  version = "0-unstable-2026-08-24";

  src = fetchFromGitHub {
    owner = "elastic";
    repo = "devfiler";
    rev = "429ef146cc763846c379730764d7d64c93fc0f9d";
    hash = "sha256-CH7zAOjBwMFvFEqhkQ4vF2uGuiv0x+Eou42Nt/f4cek=";
    fetchSubmodules = true;
  };

  cargoLock.lockFile = ./Cargo.lock;

  # Bump rocksdb crate 0.22.0 -> 0.24.0 (librocksdb-sys 0.16 -> 0.17, RocksDB
  # 8.10 -> 10.4) to get GCC 15 compatibility. Also drop the rocksdb jemalloc
  # feature to avoid a tikv-jemalloc-sys version conflict with devfiler's own
  # global allocator dependency.
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
    cp ${./Cargo.toml} Cargo.toml
  '';

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
