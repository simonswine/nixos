{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  nodejs_26,
  pkg-config,
  cmake,
  libopus,
  python3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sdrmm";
  version = "unstable-2026-09-16";

  src = fetchFromGitHub {
    owner = "Newspicel";
    repo = "sdrminusminus";
    rev = "840dc2e4d27208b1e7a8d2a294949335964216be";
    hash = "sha256-sHngWPN1R59kxr6ogFmjaTVvlNnfCByBuh0+TWqMTf4=";
  };

  cargoLock = {
    lockFile = "${finalAttrs.src}/Cargo.lock";
    outputHashes = {
      "xng-acars-0.21.0" = "sha256-Gaws7KiS6VDkJdctJV9vzvFfWEInDGf7GledbLmouUk=";
    };
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    sourceRoot = "${finalAttrs.src.name}/web";
    fetcherVersion = 4;
    hash = "sha256-4Bg6DVlnWrJkxCvZIqqBaswy3WaMl6jpkUHf0xL7UV0=";
  };
  pnpmRoot = "web";

  ffmpegSrc = fetchurl {
    url = "https://ffmpeg.org/releases/ffmpeg-9.0.1.tar.xz";
    hash = "sha256-zzjg4ox+VgWULEp3dVNJsBRYBKOXrzfrH7THfLI39jU=";
  };

  nativeBuildInputs = [
    cmake
    rustPlatform.bindgenHook
    nodejs_26
    pkg-config
    pnpm
    pnpmConfigHook
  ];

  buildInputs = [
    libopus
  ];

  # Upstream uses nightly-only Cargo settings for development checks. They are
  # not needed to build the server and prevent using the supported Rust 1.98.
  postPatch = ''
    rm -f .cargo/config.toml
  '';

  preBuild = ''
    # Bindings are generated from the restricted FFmpeg version upstream tests
    # against; Nixpkgs' newer FFmpeg exposes incompatible parser types.
    ${python3}/bin/python3 scripts/build-media.py --archive "$ffmpegSrc" --prefix "$PWD/.media"
    export FFMPEG_DIR="$PWD/.media"
    pnpm --dir web build
  '';

  cargoBuildFlags = [
    "--package"
    "sdrmm"
    "--no-default-features"
    "--features"
    "soapy,sdrplay,cr8,rtlsdr,hackrf,airspy,airspyhf,ad936x,net-client,gpu-fft"
  ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;

  doCheck = false;

  meta = {
    description = "Headless SDR-- software-defined radio server";
    homepage = "https://github.com/Newspicel/sdrminusminus";
    license = lib.licenses.gpl3Plus;
    mainProgram = "sdrmm";
    platforms = lib.platforms.linux;
  };
})
