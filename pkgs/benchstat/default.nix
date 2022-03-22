{ lib, buildGoModule, fetchgit }:

buildGoModule {
  name = "benchstat";
  version = "2022-03-22";

  src = fetchgit {
    url = "https://go.googlesource.com/perf";
    rev = "96728ec1d780dddcaaa538b0eb0eefa5c07faf8f";
    sha256 = "F4csowAFvTgJrDtnfISfdfoaFNhpJRV15zN6FbfTaN0=";
  };

  vendorSha256 = "QE/X/D6Mld/1ns1MLR3xdqs7ezsjlTG8M9zAtPIw35Y=";

  subPackages = [ "cmd/benchstat" ];
}
