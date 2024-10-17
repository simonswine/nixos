{ fetchFromGitHub, poetry2nix, ... }:

poetry2nix.mkPoetryApplication {
  pname = "mtv_dl";
  version = "0.21.5";

  projectDir = fetchFromGitHub {
    owner = "fnep";
    repo = "mtv_dl";
    rev = "7d071c9f3057220a28a7e39708d6072c555fcfb3";
    sha256 = "pEU/GAHH4XW27rYsqv/XYELov/efvbXOZIzd2nbhJdM=";
  };

  poetrylock = ./poetry.lock;
}
