{
  lib,
  buildGo126Module,
  fetchFromGitHub,
  sqlite,
  pkg-config,
  git,
}:

let
  version = "0.88.0";

  src = fetchFromGitHub {
    owner = "kdlbs";
    repo = "kandev";
    tag = "v${version}";
    hash = "sha256-YLJ6shH/CCh7I8412Fw6tVuma4bCiBFheH9BDM49T1k=";
  };

in

buildGo126Module {
  pname = "kandev";
  inherit version src;

  modRoot = "apps/backend";

  vendorHash = "sha256-68fOqzojvBNAFL6MDw7G8NpLf1PBgAjwJipQcWdple8=";

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
    "-X main.Commit=cab9eaf"
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
