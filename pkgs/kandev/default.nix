{
  lib,
  buildGo126Module,
  fetchFromGitHub,
  sqlite,
  pkg-config,
  git,
}:

let
  version = "0.79.0";

  src = fetchFromGitHub {
    owner = "kdlbs";
    repo = "kandev";
    tag = "v${version}";
    hash = "sha256-AaVEIZaFfw3xuhs99J0y+CgYQqZ9KqAo9eUaJ8ImAXg=";
  };

in

buildGo126Module {
  pname = "kandev";
  inherit version src;

  modRoot = "apps/backend";

  vendorHash = "sha256-S3mVvmd6GDySS8hsmzUyZNlzZM1gYuT4uOWCs/gm7ek=";

  env.CGO_ENABLED = "1";

  nativeBuildInputs = [
    pkg-config
    git
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
    "-X main.Commit=f9f2da2"
  ];

  meta = {
    description = "AI Kanban & Development Environment orchestrating multiple AI coding agents";
    homepage = "https://github.com/kdlbs/kandev";
    changelog = "https://github.com/kdlbs/kandev/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "kandev";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
