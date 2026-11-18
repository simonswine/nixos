{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "rustledger";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "rustledger";
    repo = "rustledger";
    rev = "v${version}";
    hash = "sha256-c5AdipaaMf52Sg84tLN3tcy2ltdVSg43Jv5Qkg1PLe4=";
  };

  cargoHash = "sha256-M5dN+u6g+bY4uYbKKiCbJEFdxCbz41Zhlf0m2rYx6ps=";

  cargoBuildFlags = [
    "-p"
    "rustledger"
    "-p"
    "rustledger-lsp"
  ];
  buildFeatures = [
    "ag-rledger"
    "mimalloc"
  ];
  doCheck = false;

  meta = {
    description = "Modern plain text accounting compatible with Beancount";
    homepage = "https://rustledger.github.io";
    changelog = "https://github.com/rustledger/rustledger/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "rledger";
  };
}
