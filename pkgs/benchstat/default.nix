{ lib, buildGoModule, fetchgit }:

buildGoModule {
  name = "benchstat";
  version = "2022-04-11";

  src = fetchgit {
    url = "https://go.googlesource.com/perf";
    rev = "84e58bfe0a7e5416369e236afa007d5d9c58a0fa";
    sha256 = "1q3tjPrWZtBIXf/W+0XhFvCciQp1DHTeI3PRKaqsLTI=";
  };

  vendorHash = "sha256-d/4LB2ei3g0f1AiDwCDVBcvL+GUbdUvb5IqcorEb01s=";

  subPackages = [ "cmd/benchstat" ];
}
