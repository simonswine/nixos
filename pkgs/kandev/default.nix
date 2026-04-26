{
  lib,
  stdenv,
  buildGo126Module,
  fetchFromGitHub,
  pnpm,
  nodejs,
  sqlite,
  pkg-config,
  makeWrapper,
}:

let
  version = "0.37";

  src = fetchFromGitHub {
    owner = "kdlbs";
    repo = "kandev";
    tag = "v${version}";
    hash = "sha256-gZJq3ODNtyn+hLZ3TYn8ezLm3Qu12teqRHYWoY61R9Y=";
  };

  # Build the Next.js frontend (standalone output) using pnpm workspace.
  # The pnpm workspace root is apps/; the web package is apps/web/.
  # Next.js standalone for a monorepo produces:
  #   .next/standalone/
  #     web/server.js    <- actual entry point
  #     web/.next/       <- server-side bundles
  #     node_modules/    <- minimal shared deps
  # Static and public assets must be placed adjacent to server.js.
  kandev-web = stdenv.mkDerivation (finalAttrs: {
    pname = "kandev-web";
    inherit version src;

    sourceRoot = "${src.name}/apps";

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
    ];

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      sourceRoot = "${src.name}/apps";
      fetcherVersion = 3;
      hash = "sha256-D4r2HwMDWiNVu2vCGd0UqNEvN4Snc3IAqSV92AX7/CY=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm --filter @kandev/web build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      # Copy standalone output (gives us web/server.js and node_modules/)
      cp -r web/.next/standalone/. "$out/"
      # Place static and public assets adjacent to server.js, as Next.js requires
      mkdir -p "$out/web/.next"
      cp -r web/.next/static "$out/web/.next/static"
      cp -r web/public "$out/web/public"
      runHook postInstall
    '';
  });

in

buildGo126Module {
  pname = "kandev";
  inherit version src;

  # Go module lives in apps/backend/
  modRoot = "apps/backend";

  vendorHash = "sha256-7vc/hRjyylwou9ehFi0rR9evB4cyhSFZAPf/V8JgJhY=";

  # mattn/go-sqlite3 requires CGO
  env.CGO_ENABLED = "1";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [ sqlite ];

  subPackages = [
    "cmd/kandev"
    "cmd/agentctl"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
    "-X main.Commit=f48855e"
  ];

  postInstall =
    let
      webDir = "${placeholder "out"}/share/kandev/web";
      nodeServerJs = "${webDir}/web/server.js";
      nodeBin = "${nodejs}/bin/node";
    in
    ''
      # Install the Next.js standalone server
      mkdir -p "$out/share/kandev/web"
      cp -r ${kandev-web}/. "$out/share/kandev/web/"

      # Rename the Go binary so we can wrap it with a shell script
      mv "$out/bin/kandev" "$out/bin/.kandev-bin"

      # Create a wrapper that starts the Next.js server alongside the Go backend.
      # The Go backend reverse-proxies all non-API requests via KANDEV_WEB_INTERNAL_URL.
      makeWrapper "$out/bin/.kandev-bin" "$out/bin/kandev" \
        --run '
          _web_port="''${KANDEV_WEB_PORT:-37429}"
          _web_dir="${webDir}"
          HOSTNAME=127.0.0.1 PORT="$_web_port" \
            ${nodeBin} ${nodeServerJs} &
          _web_pid=$!
          _cleanup() { kill "$_web_pid" 2>/dev/null; wait "$_web_pid" 2>/dev/null; }
          trap _cleanup EXIT INT TERM
        ' \
        --set-default KANDEV_WEB_INTERNAL_URL "http://127.0.0.1:37429"
    '';

  meta = {
    description = "AI Kanban & Development Environment orchestrating multiple AI coding agents";
    homepage = "https://github.com/kdlbs/kandev";
    changelog = "https://github.com/kdlbs/kandev/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "kandev";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
