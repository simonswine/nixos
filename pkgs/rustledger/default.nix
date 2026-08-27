{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "rustledger";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "rustledger";
    repo = "rustledger";
    rev = "v${version}";
    hash = "sha256-KNInYM3pVhVxTyP94FJJFOKMy25u+NFOqO1ZR+NXc6A=";
  };

  cargoHash = "sha256-q6cUezD2VJICm2dfp8kYV4TvUbkBEY3Xfs0EBErRa60=";

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
