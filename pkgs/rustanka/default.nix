{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "rustanka";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "rustanka";
    rev = "v${version}";
    hash = "sha256-Zby9wE6+WF5zXCX7KtJEQ1i0Q+g6g9Za03tLNXrycG4=";
  };

  cargoHash = "sha256-iWFyDOBtgA2Osu6AGAlGdpuK3ESouKBFpT86wvwhzlw=";
  cargoBuildFlags = [
    "-p"
    "rtk"
    "--features"
    "kube/socks5"
  ];
  doCheck = false;

  meta = {
    description = "Rust implementation of Tanka for Kubernetes deployments";
    homepage = "https://github.com/grafana/rustanka";
    changelog = "https://github.com/grafana/rustanka/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "rtk";
  };
}
