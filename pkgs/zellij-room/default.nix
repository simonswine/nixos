{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "1.2.1";
in
stdenvNoCC.mkDerivation {
  pname = "zellij-room";
  inherit version;

  src = fetchurl {
    url = "https://github.com/rvcas/room/releases/download/v${version}/room.wasm";
    hash = "sha256-kLSDpAt2JGj7dYYhYFh6BfvtzVwTrcs+0jHwG/nActE=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/lib/zellij/plugins/room.wasm
    runHook postInstall
  '';

  meta = {
    description = "Zellij WASM plugin for fuzzy session/tab/pane switching";
    homepage = "https://github.com/rvcas/room";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
