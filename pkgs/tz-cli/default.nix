{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tz-cli";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "oz";
    repo = "tz";
    rev = "v${version}";
    hash = "sha256-OpftKCEoAltvQw0bB3SyFeXUDiGjVHNDrrKsdRH6zl4=";
  };

  vendorHash = "sha256-Mdp2bcqTawbeqdu06QfB4atLaPpPDoE/eisTytxCnj4=";

  subPackages = [ "." ];

  checkPhase = "";

  meta = with lib; {
    description = "tz helps you schedule things across time zones. It is an interactive TUI program that displays time across a few time zones of your choosing.";
    homepage = "https://github.com/oz/tz";
    license = licenses.gpl3;
    maintainers = lib.optional (lib.maintainers ? simonswine) lib.maintainers.simonswine;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
