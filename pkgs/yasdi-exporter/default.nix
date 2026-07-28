{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  yasdi,
}:

let
  libraryPathVar = if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
in
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

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace yasdi/{connection,device}.go \
      --replace-fail '-l:libyasdimaster.so.1' '-lyasdimaster'
  '';

  CGO_LDFLAGS = "-L${yasdi}/lib";

  postInstall = ''
    wrapProgram $out/bin/yasdi_exporter \
      --prefix ${libraryPathVar} : "${lib.makeLibraryPath [ yasdi ]}"
  '';

  buildInputs = [ yasdi ];
}
