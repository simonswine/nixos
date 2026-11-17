{
  lib,
  stdenv,
  pnpm_10_latest,
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

  # Use the patched pnpm 10 variant: pnpm_10 is frozen at insecure 10.34.0.
  # The nixpkgs hooks disable manage-package-manager-versions so upstream's
  # insecure pnpm 9 pin is not honoured.
  nativeBuildInputs = [
    nodejs
    pnpm_10_latest
    (pnpmConfigHook.override { pnpm = pnpm_10_latest; })
  ];

  pnpmDeps = (fetchPnpmDeps.override { pnpm = pnpm_10_latest; }) {
    pname = "kandev-frontend";
    inherit version src;
    sourceRoot = "${src.name}/apps";
    fetcherVersion = 3;
    hash = "sha256-/Dh8TMSapZh6c/QCJi3IsHLIqBFJCqm1yERbc6w3fVM=";
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
