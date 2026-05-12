{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "fluidcad";
  version = "0.0.33";

  src = fetchFromGitHub {
    owner = "Fluid-CAD";
    repo = "FluidCAD";
    rev = "v${version}";
    hash = "sha256-N9xLYxsZY3UQ7L+BuxZm8bUQb9Voj9H4hSK7/6/mLaI=";
  };

  npmDepsHash = "sha256-jQjTb6TEUtJtMUQaQqGCMcH7aiGga5CR1M5ySs0cUeM=";

  postInstall = ''
    # The npm workspace for extension/vscode creates a dangling symlink in the
    # installed package since the VSCode extension source is not part of the dist.
    rm -f $out/lib/node_modules/fluidcad/node_modules/fluidcad

    # Remove fluidcad from ssr.external so Vite resolves it via our plugin
    # rather than Node's require, which would fail since the package lives in
    # the Nix store rather than the user's node_modules.
    sed -i \
      "s|external: \['fluidcad'\]|external: []|" \
      "$out/lib/node_modules/fluidcad/server/dist/vite-manager.js"

    # Inject a resolveId plugin that maps all fluidcad subpath exports to their
    # absolute Nix store paths. A simple resolve.alias wouldn't work here
    # because Vite's string alias does a prefix substitution (fluidcad/core ->
    # /store/path/core) which bypasses the package.json exports map.
    sed -i \
      "s|plugins: \[|plugins: [{ name: 'fluidcad-resolver', resolveId(id) { const m = { 'fluidcad': '$out/lib/node_modules/fluidcad/lib/dist/index.js', 'fluidcad/core': '$out/lib/node_modules/fluidcad/lib/dist/core/index.js', 'fluidcad/filters': '$out/lib/node_modules/fluidcad/lib/dist/filters/index.js', 'fluidcad/constraints': '$out/lib/node_modules/fluidcad/lib/dist/features/2d/constraints/geometry-qualifier.js', 'fluidcad/math': '$out/lib/node_modules/fluidcad/lib/dist/math/index.js' }; return m[id]; } },|" \
      "$out/lib/node_modules/fluidcad/server/dist/vite-manager.js"
  '';

  meta = {
    description = "Parametric CAD modeling tool – write 3D models in JavaScript with real-time 3D preview";
    homepage = "https://fluidcad.io";
    license = lib.licenses.lgpl21;
    mainProgram = "fluidcad";
  };
}
