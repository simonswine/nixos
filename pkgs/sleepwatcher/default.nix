{ stdenv, fetchurl, darwin }:

stdenv.mkDerivation rec {
  pname = "sleepwatcher";
  version = "2.2.1";

  src = fetchurl {
    url = "https://www.bernhard-baehr.de/sleepwatcher_${version}.tgz";
    sha256 = "S/FlZwIWeHEUH7wRmoRNE2PYmZThpnAn8OdzAjrpZD4=";
  };

  buildInputs = [ darwin.apple_sdk.frameworks.Carbon ];

  buildPhase = ''
    mkdir -p bin
    cc -O3 -mmacosx-version-min=10.4 -o bin/sleepwatcher ./sources/sleepwatcher.c -framework IOKit -framework CoreFoundation
  '';

  installPhase = ''
    mkdir -p $out -p
    cp -R bin $out
  '';
}

