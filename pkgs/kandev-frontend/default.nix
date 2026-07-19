{
  lib,
  stdenv,
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
    nodejs
    pnpm_9
    (pnpmConfigHook.override { pnpm = pnpm_9; })
  ];

  pnpmDeps = (fetchPnpmDeps.override { pnpm = pnpm_9; }) {
    pname = "kandev-frontend";
    inherit version src;
    sourceRoot = "${src.name}/apps";
    fetcherVersion = 3;
    hash = "sha256-3HJC2cZQd+D5SDmKLxzQqe91xyQbdxalcGQROafxTG0=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm --filter @kandev/web build
    runHook postBuild
  '';

  # The backend serves these Vite assets when KANDEV_WEB_DIST_DIR points here.
  installPhase = ''
    runHook preInstall
    cp -r web/dist "$out"
    runHook postInstall
  '';

  meta = {
    description = "Vite frontend assets for kandev";
    homepage = "https://github.com/kdlbs/kandev";
    changelog = "https://github.com/kdlbs/kandev/releases/tag/v${version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
