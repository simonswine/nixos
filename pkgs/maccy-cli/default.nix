{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "maccy-cli";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "maccy-cli";
    rev = "v${version}";
    hash = "sha256-8Oqro7cpCWZnwYyXr+8NomxcKONpnwNmXI2jFUxF2qM=";
  };

  vendorHash = "sha256-tZPWYzhZxrFFvSLmV6lnvi1faCrjXClqKR9R6Yga+ng=";
  subPackages = [ "." ];
  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Read and select clipboard history from Maccy";
    homepage = "https://github.com/simonswine/maccy-cli";
    mainProgram = "maccy-cli";
    platforms = lib.platforms.darwin;
  };
}
