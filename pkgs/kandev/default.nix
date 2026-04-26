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

  # Build the Next.js frontend (standalone output) using pnpm workspace
  kandev-web = stdenv.mkDerivation (finalAttrs: {
    pname = "kandev-web";
    inherit version src;

    # pnpm workspace root is apps/
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

    # Next.js standalone output: server.js + minimal node_modules + .next/
    # Static assets and public/ must be copied alongside per Next.js docs.
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r web/.next/standalone/. "$out/"
      mkdir -p "$out/.next"
      cp -r web/.next/static "$out/.next/static"
      cp -r web/public "$out/public"
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

  postInstall = ''
    # Install the Next.js standalone server alongside the Go binary
    mkdir -p "$out/share/kandev/web"
    cp -r ${kandev-web}/. "$out/share/kandev/web/"

    # Ensure nodejs is on PATH so kandev can start the Next.js server process
    wrapProgram "$out/bin/kandev" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
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
