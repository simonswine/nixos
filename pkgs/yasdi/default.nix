{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation {
  name = "yasdi";
  version = "1.8.1.9.1";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "libyasdi";
    rev = "23b799dc70a9d6f87a5ba86223719578d4e11c71";
    sha256 = "FounFvmzW3lVJ3PBaXtIEljer5QDOmy7M61H/A6ZrA0=";
  };

  postInstall = ''
    mkdir -p $out/include
    cp $src/include/*.h $out/include
    cp $src/smalib/*.h $out/include
    cp $src/libs/*.h $out/include
  '';

  prePatch = ''
    cd projects/generic-cmake
  '';

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'CMAKE_MINIMUM_REQUIRED(VERSION 2.4)' 'CMAKE_MINIMUM_REQUIRED(VERSION 3.5)' \
      --replace-fail 'CMAKE_POLICY(SET CMP0003 OLD)' 'CMAKE_POLICY(SET CMP0003 NEW)'
    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace ../../os/os_linux.h \
        --replace-fail '#include <termio.h>' '#include <termios.h>'
    ''}
  '';

  nativeBuildInputs = [ cmake ];
}
