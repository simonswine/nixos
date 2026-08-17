{
  lib,
  stdenv,
  pnpm_10,
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

  # Upstream pins pnpm 9 via package.json's packageManager field, but
  # nixpkgs' pnpm_9 (9.15.9) is flagged insecure. pnpm 10 reads the same
  # lockfileVersion 9.0 lockfile, and the nixpkgs pnpm hooks disable
  # manage-package-manager-versions so the pin is not honoured.
  nativeBuildInputs = [
    nodejs
    pnpm_10
    (pnpmConfigHook.override { pnpm = pnpm_10; })
  ];

  pnpmDeps = (fetchPnpmDeps.override { pnpm = pnpm_10; }) {
    pname = "kandev-frontend";
    inherit version src;
    sourceRoot = "${src.name}/apps";
    fetcherVersion = 3;
    hash = "sha256-QuY8H2Lt/uK46Tfh+QAMUHnug/YiXBY8h1Ffzi5mSCg=";
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
