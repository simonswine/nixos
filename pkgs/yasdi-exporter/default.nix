{ lib, buildGoModule, fetchFromGitHub, makeWrapper, yasdi }:

buildGoModule {
  name = "yasdi-exporter";
  version = "a4d2ea7";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "yasdi_exporter";
    rev = "a4d2ea7d5010ce518be9f24f9cbff27107555781";
    sha256 = "T4PPbhFkZ6oAn0vTzhS1czps2/nH+iYv4JY/wqdN30U=";
  };
  vendorSha256 = "3vc2o5ywylrUr2fCxNoqKVWcOmFQGSHj/+fWVbvaJ/4=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/yasdi_exporter \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ yasdi ]}"
  '';

  buildInputs = [ yasdi ];
}
