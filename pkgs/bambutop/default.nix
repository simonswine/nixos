{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "bambutop";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "rhoopr";
    repo = "bambutop";
    rev = "v${version}";
    hash = "sha256-WK3riPD3hrsXj3QL5mRsF6Q9hWjiEe6l1RaE2INydzA=";
  };

  cargoHash = "sha256-BeHx0Jksh5rFzNk4PaY+CNNkJV/c9qPuWUSIojGf9PY=";

  meta = {
    description = "Terminal-based status monitor for Bambu Labs printers";
    homepage = "https://github.com/rhoopr/bambutop";
    changelog = "https://github.com/rhoopr/bambutop/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "bambutop";
  };
}
