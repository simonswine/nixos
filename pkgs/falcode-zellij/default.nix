{
  lib,
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
}:
let
  # Released WASM popup binary — stable v0.0.11
  wasmVersion = "0.0.11";
  wasm = fetchurl {
    url = "https://github.com/victor-falcon/falcode-zellij/releases/download/v${wasmVersion}/falcode-zellij-sessions.wasm";
    hash = "sha256-nMRBpKwIGgX+dsNnZ9baSCPvP0asm0DG2R6pOSW8bkg=";
  };

  # Scripts / plugins from main (includes Claude hook + zellij-attention pipes)
  mainRev = "972df9c2b7c3741c9cea88dbae50b4547b344ca2";
  src = fetchFromGitHub {
    owner = "victor-falcon";
    repo = "falcode-zellij";
    rev = mainRev;
    hash = "sha256-0ekNMUyoOh/I94mz4mq35EF9Vg2K213PCMr6DetekGE=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "falcode-zellij";
  version = "${wasmVersion}-${builtins.substring 0 7 mainRev}";

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Zellij WASM popup
    install -Dm644 ${wasm} $out/lib/zellij/plugins/falcode-zellij-sessions.wasm

    # OpenCode JS plugin (loaded by opencode at runtime via plugin[] config)
    install -Dm644 ${src}/opencode-plugin/falcode.js $out/lib/opencode/plugins/falcode.js

    # Claude Code hook script
    install -Dm755 ${src}/claude-extension/falcode-hook.sh $out/lib/claude-extension/falcode-hook.sh

    # macOS notification helper
    install -Dm755 ${src}/scripts/oc-notify.sh $out/lib/scripts/oc-notify.sh

    # Notification icon (optional, used by oc-notify.sh for -contentImage)
    install -Dm644 ${src}/assets/opencode-icon.icns $out/lib/assets/opencode-icon.icns 2>/dev/null || true

    runHook postInstall
  '';

  meta = {
    description = "Zellij plugin that shows active AI agent panes (OpenCode/Claude) in a floating popup";
    homepage = "https://github.com/victor-falcon/falcode-zellij";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
