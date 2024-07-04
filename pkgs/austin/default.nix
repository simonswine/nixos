{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, autoreconfHook
}:

stdenv.mkDerivation rec {
  pname = "austin";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "P403n1x87";
    repo = "austin";
    rev = "v${version}";
    hash = "sha256-ls9dOEHjCXj1vlv7TWHJijVkhqCmdC/GT5Ps37HPF2M=";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook ];
  buildInputs = [ ];

  meta = with lib; {
    description = "A Frame Stack Sampler for CPython";
    homepage = "https://github.com/P403n1x87/austin";
    maintainers = with maintainers; [ simonswine ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
