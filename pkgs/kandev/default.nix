{
  lib,
  buildGo126Module,
  fetchFromGitHub,
  sqlite,
  pkg-config,
}:

let
  version = "0.51.0";

  src = fetchFromGitHub {
    owner = "kdlbs";
    repo = "kandev";
    tag = "v${version}";
    hash = "sha256-lELJRMPs9fUqif9cp6UsZl4MyXSonEkJnYk756DZEp0=";
  };

in

buildGo126Module {
  pname = "kandev";
  inherit version src;

  modRoot = "apps/backend";

  vendorHash = "sha256-83LgMQdZIbRRhrIqWop7NX3WxhkFS3johs1PydTBKmE=";

  env.CGO_ENABLED = "1";

  nativeBuildInputs = [ pkg-config ];
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
