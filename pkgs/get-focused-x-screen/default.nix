{
  pkgs,
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
}:

buildGoModule rec {
  pname = "get-focused-x-screen";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "get-focused-x-screen";
    rev = "v${version}";
    hash = "sha256-ZxHatg/6b86neyeKlJ61TCv8Ex+WloVCbOzp3LEXf/Q=";
  };

  vendorHash = "sha256-xgkUFRCKNv+19dcCk+0gOL9SS7DZ9xz4ytiLYdAo4E4=";

  subPackages = [ "." ];

  nativeBuildInputs = [ makeWrapper ];

  meta = with lib; {
    description = "Little tool that outputs the XWAYLAND<n> name of the current focused sway output";
    homepage = "https://github.com/simonswine/get-focused-x-screen";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
