{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tz-cli";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "oz";
    repo = "tz";
    rev = "v${version}";
    sha256 = "1wmrvl5n1x1id30p0nsn05mjxiyvmdva18j3g5fh137ixrmd7afz";
  };

  vendorSha256 = "0z36y9pf1j7wdwnrbs0h965sdf7l6g8c82in5vwascg8ivnbr1ja";

  subPackages = [ "." ];

  checkPhase = "";

  meta = with lib; {
    description = "tz helps you schedule things across time zones. It is an interactive TUI program that displays time across a few time zones of your choosing.";
    homepage = "https://github.com/oz/tz";
    license = licenses.gpl3;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
