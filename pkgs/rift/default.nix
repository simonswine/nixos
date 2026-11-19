{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  iconv,
}:

rustPlatform.buildRustPackage {
  pname = "rift";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift";
    rev = "v0.8.3";
    hash = "sha256-8imLFJ90Ovb9y19iTN+JgQ+FtiKx7pbgpPzdSl4Agug=";
  };

  cargoHash = "sha256-OOQhpopVGKhS2QHfRuapVBx6bZdZAxNlOHM54c5JvxI=";

  # Tests exercise global input hooks and WindowServer bridges, which are not
  # available reliably inside the Nix build sandbox.
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    iconv
  ];

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "rift";
    platforms = platforms.darwin;
  };
}
