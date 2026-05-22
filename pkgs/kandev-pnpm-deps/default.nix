{
  pnpm,
  fetchFromGitHub,
}:

let
  version = "0.50.0";

  src = fetchFromGitHub {
    owner = "kdlbs";
    repo = "kandev";
    tag = "v${version}";
    hash = "sha256-tdZ46Q7p0RljZ3Rr9ESJoVysxYicEl3DNKUhaY39Q1Q=";
  };
in
pnpm.fetchDeps {
  pname = "kandev-pnpm-deps";
  inherit version src;
  sourceRoot = "${src.name}/apps";
  fetcherVersion = 3;
  hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
