{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "jsonnet-language-server";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "jsonnet-language-server";
    rev = "v${version}";
    hash = "sha256-4tJrEipVbiYQY0L9sDH0f/qT8WY7c3md/Bar/dST+VI=";
  };
  vendorHash = "sha256-/mfwBHaouYN8JIxPz720/7MlMVh+5EEB+ocnYe4B020=";

  meta = with lib; {
    description = "A Language Server Protocol server for Jsonnet";
    homepage = "https://github.com/grafana/jsonnet-language-server";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [
      jdbaldry
      simonswine
    ];
  };
}
