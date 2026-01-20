{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  name = "goda";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "loov";
    repo = "goda";
    rev = "v${version}";
    sha256 = "24mZMFitDUGrfi4G1IpoZymoIFqtj4VPxQx9vI7WTSY=";
  };
  vendorHash = "sha256-inoFHNyNMCh+cffjNb9EI7EVvHjXGBG9+BbJsCAw2d8=";
}
