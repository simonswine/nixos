{
  lib,
  stdenv,
  pnpm,
  nodejs,
  version,
  src,
}:

stdenv.mkDerivation {
  pname = "kandev-frontend";
  inherit version src;

  sourceRoot = "${src.name}/apps";

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  pnpmDeps = pnpm.fetchDeps {
    pname = "kandev-frontend";
    inherit version src;
    sourceRoot = "${src.name}/apps";
    fetcherVersion = 3;
    hash = "sha256-t4/dzf3TPzqHHkPEzfCePW23ZqT/526iU6RnJQXCcnw=";
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
    runHook postInstall
  '';

  meta = {
    description = "Next.js frontend for kandev";
    homepage = "https://github.com/kdlbs/kandev";
    changelog = "https://github.com/kdlbs/kandev/releases/tag/v${version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
