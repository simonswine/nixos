{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "rustanka";
  version = "0.0.34";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "rustanka";
    rev = "v${version}";
    hash = "sha256-wGI/2cey+Mu6+5VczJ84p0L3woxU5k3MmejGNy6fARg=";
  };

  cargoHash = "sha256-bLxTrMhvT6JWY4m1qXTmXrpGbuf0zTmpDmvkKWOpCPs=";
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
