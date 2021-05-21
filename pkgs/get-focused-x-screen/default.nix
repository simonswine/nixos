{ pkgs, lib, buildGoModule, fetchFromGitHub, makeWrapper }:


buildGoModule rec {
  pname = "get-focused-x-screen";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "get-focused-x-screen";
    rev = "v${version}";
    sha256 = "1x3z2yqxrsgcdi18b5ln3w9zqascnng992i7gfkwwvzs1yvdl4b7";
  };

  vendorSha256 = "0kp0538632yqrbw1rxyrn15m5grq43nr60npynszydla20ai82f6";

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
