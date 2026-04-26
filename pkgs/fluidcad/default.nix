{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "fluidcad";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "Fluid-CAD";
    repo = "FluidCAD";
    rev = "v${version}";
    hash = "sha256-NjR0TV7vx7oVrk43ZNvRdIteBaDdKnOtMM+hM0jJYQg=";
  };

  npmDepsHash = "sha256-gK0/yNtr3+uKiziowOHp13ajJLOA5aOHe1qYCY+58X4=";

  postInstall = ''
    # The npm workspace for extension/vscode creates a dangling symlink in the
    # installed package since the VSCode extension source is not part of the dist.
    rm -f $out/lib/node_modules/fluidcad/node_modules/fluidcad

    # Patch vite-manager.js so that user scripts can `import 'fluidcad'` without
    # having it installed locally. Vite SSR resolves modules from the user's
    # workspace; we redirect 'fluidcad' to the Nix store via resolve.alias and
    # mark it noExternal so it goes through Vite's resolver rather than Node's.
    sed -i \
      "s|root: rootPath,|root: rootPath, resolve: { alias: { fluidcad: '$out/lib/node_modules/fluidcad' } }, ssr: { noExternal: ['fluidcad'] },|" \
      "$out/lib/node_modules/fluidcad/server/dist/vite-manager.js"
  '';

  meta = {
    description = "Parametric CAD modeling tool – write 3D models in JavaScript with real-time 3D preview";
    homepage = "https://fluidcad.io";
    license = lib.licenses.lgpl21;
    mainProgram = "fluidcad";
  };
}
