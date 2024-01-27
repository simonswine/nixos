{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tz-cli";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "oz";
    repo = "tz";
    rev = "v${version}";
    hash = "sha256-Mnb0GdJ9dgaUanWBP5JOo6++6MfrUgncBRp4NIbhxf0=";
  };

  vendorHash = "sha256-lcCra4LyebkmelvBs0Dd2mn6R64Q5MaUWc5AP8V9pec=";

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
