{
  lib,
  applyPatches,
  buildPackages,
  fetchFromGitHub,
  pkgsCross,
}:
let
  version = "0.3.1";
in
pkgsCross.wasi32.rustPlatform.buildRustPackage {
  pname = "zellij-attention";
  inherit version;

  src = applyPatches {
    src = fetchFromGitHub {
      owner = "KiryuuLight";
      repo = "zellij-attention";
      rev = "v${version}";
      hash = "sha256-T36mzLbXCUqBeLa5hUX4/gMZ/c41szKAcLrsyXB6TIQ=";
    };
    patches = [ ./question-icon.patch ];
  };

  cargoHash = "sha256-kXBfhSrb0UQ6tmM7I9tmQOii1JPCYOS9rcRbse0i89Q=";
  postPatch = ''
    substituteInPlace .cargo/config.toml \
      --replace-fail @wasm-ld@ ${buildPackages.llvmPackages.lld}/bin/wasm-ld
  '';
  buildPhase = ''
    cargo build --offline --release --target wasm32-wasip1 \
      --config 'target.wasm32-wasip1.linker="${buildPackages.llvmPackages.lld}/bin/wasm-ld"'
  '';
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm644 target/wasm32-wasip1/release/zellij-attention.wasm $out/lib/zellij/plugins/zellij-attention.wasm
    runHook postInstall
  '';

  meta = {
    description = "Zellij WASM plugin that adds attention notification icons to tab names";
    homepage = "https://github.com/KiryuuLight/zellij-attention";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
