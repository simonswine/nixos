{
  stdenv,
  fetchFromGitHub,
  lib,
  git,
}:

stdenv.mkDerivation rec {
  pname = "phpspy";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "adsr";
    repo = "phpspy";
    rev = "v${version}";
    hash = "sha256-iQOeZLHRc5yUgXc6xz52t/6oc07eZfH5ZgzSdJBcaak=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ git ];

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin
    cp -v phpspy $out/bin/phpspy
  '';

  meta = with lib; {
    description = "phpspy is a low-overhead sampling profiler for PHP 7.0+";

    longDescription = ''
      phpspy is a low-overhead sampling profiler for PHP. It works with non-ZTS
      PHP 7.0+ with CLI, Apache, and FPM SAPIs on 64-bit Linux 3.2+.
    '';

    homepage = "http://github.com/adsr/phpspy";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
