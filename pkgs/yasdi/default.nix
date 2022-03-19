{ stdev, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "yasdi";
  version = "1.8.1.9.1";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "libyasdi";
    rev = "23b799dc70a9d6f87a5ba86223719578d4e11c71";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  nativeBuildInputs = [ gettext pkg-config ];
  buildInputs = [ ncurses ];

  configureFlags = [ ];
}
