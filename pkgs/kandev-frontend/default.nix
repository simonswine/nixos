{
  lib,
  stdenv,
  makeWrapper,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  version,
  src,
}:

stdenv.mkDerivation {
  pname = "kandev-frontend";
  inherit version src;

  sourceRoot = "${src.name}/apps";

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm_9
    (pnpmConfigHook.override { pnpm = pnpm_9; })
  ];

  pnpmDeps = (fetchPnpmDeps.override { pnpm = pnpm_9; }) {
    pname = "kandev-frontend";
    inherit version src;
    sourceRoot = "${src.name}/apps";
    fetcherVersion = 3;
    hash = "sha256-H+/g0LslvlXI/zscUKCWH1Zh5JHR+wiWfynBk7BbBbc=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm --filter @kandev/web build
    runHook postBuild
  '';

  # Next.js standalone for a monorepo produces:
  #   .next/standalone/
  #     web/server.js    <- actual entry point
  #     web/.next/       <- server-side bundles
  #     node_modules/    <- minimal shared deps
  # Static and public assets must be placed adjacent to server.js.
  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r web/.next/standalone/. "$out/"
    mkdir -p "$out/web/.next"
    cp -r web/.next/static "$out/web/.next/static"
    cp -r web/public "$out/web/public"
    makeWrapper ${lib.getExe nodejs} "$out/bin/kandev-frontend" \
      --add-flags "$out/web/server.js"
    runHook postInstall
  '';

  meta = {
    description = "Next.js frontend for kandev";
    homepage = "https://github.com/kdlbs/kandev";
    changelog = "https://github.com/kdlbs/kandev/releases/tag/v${version}";
    mainProgram = "kandev-frontend";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
