{
  lib,
  vimUtils,
  fetchFromGitHub,
  fluidcad,
  nodejs,
}:

let
  version = "0.0.33";
  src = fetchFromGitHub {
    owner = "Fluid-CAD";
    repo = "FluidCAD";
    rev = "v${version}";
    hash = "sha256-N9xLYxsZY3UQ7L+BuxZm8bUQb9Voj9H4hSK7/6/mLaI=";
  };
in

vimUtils.buildVimPlugin {
  pname = "fluidcad-nvim";
  inherit version;

  inherit src;
  sourceRoot = "source/extension/neovim";

  postInstall = ''
    # Pin the node binary used to invoke the bridge to the packaged nodejs.
    substituteInPlace $out/lua/fluidcad/bridge.lua \
      --replace-fail \
        "{ 'node', config.bridge_path, workspace_path }" \
        "{ '${nodejs}/bin/node', config.bridge_path, workspace_path }"

    # Patch bridge.cjs to default to the nix-packaged fluidcad server.
    # The FLUIDCAD_SERVER env var can still override this at runtime.
    substituteInPlace $out/bridge.cjs \
      --replace-fail \
        'let serverEntry;' \
        "let serverEntry = process.env.FLUIDCAD_SERVER || '${fluidcad}/lib/node_modules/fluidcad/server/dist/index.js';"
    substituteInPlace $out/bridge.cjs \
      --replace-fail \
        "  serverEntry = workspaceRequire.resolve('fluidcad/server');" \
        "  if (!serverEntry) serverEntry = workspaceRequire.resolve('fluidcad/server');"
  '';

  meta = {
    description = "Neovim plugin for FluidCAD parametric CAD modeling";
    homepage = "https://github.com/Fluid-CAD/FluidCAD/tree/main/extension/neovim";
    license = lib.licenses.lgpl21;
  };
}
