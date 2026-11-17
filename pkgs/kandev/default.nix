{
  lib,
  buildGo126Module,
  fetchFromGitHub,
  sqlite,
  pkg-config,
  git,
}:

let
  version = "0.101.0";

  src = fetchFromGitHub {
    owner = "kdlbs";
    repo = "kandev";
    tag = "v${version}";
    hash = "sha256-PIN4xOe0eFe5EwTIuiW8/V5r/EUxWOlEfdVmAFfZPLA=";
  };

in

buildGo126Module {
  pname = "kandev";
  inherit version src;

  modRoot = "apps/backend";

  vendorHash = "sha256-di8jMeqwa6vFA5fzBKA78R4o60viY/y4TUnJVmxwjxY=";

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
    "-X main.Commit=3c2f7e9"
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
