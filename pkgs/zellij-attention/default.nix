{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.3.1";
in
stdenvNoCC.mkDerivation {
  pname = "zellij-attention";
  inherit version;

  src = fetchurl {
    url = "https://github.com/KiryuuLight/zellij-attention/releases/download/v${version}/zellij-attention.wasm";
    hash = "sha256-QgkzerYacxRI7HMzYvPvaZqQW7tcARKpOm1hY2D9ci8=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/lib/zellij/plugins/zellij-attention.wasm
    runHook postInstall
  '';

  meta = {
    description = "Zellij WASM plugin that adds attention notification icons to tab names";
    homepage = "https://github.com/KiryuuLight/zellij-attention";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
