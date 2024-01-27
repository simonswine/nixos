{ lib, buildGoModule, fetchFromGitHub, makeWrapper, yasdi }:

buildGoModule {
  name = "yasdi-exporter";
  version = "a4d2ea7";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "yasdi_exporter";
    rev = "dcea9a5377e321b8baef32e47209ebed694a39dc";
    sha256 = "93eLb54d1+xvqz5+u0SsXkAshHX3EMe/GNCVQebEe0Q=";
  };
  vendorHash = "sha256-bfvPvZ8ZJ9G3XAJNJaFrP1AaQNyVw20Awdc0CgEtPs8=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/yasdi_exporter \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ yasdi ]}"
  '';

  buildInputs = [ yasdi ];
}
