{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "faillint";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "fatih";
    repo = "faillint";
    rev = "v${version}";
    hash = "sha256-fUtPw0Mn1x+P+4l2iSoAbPRxvB/4kyzVcX4wK9VpjZs=";
  };

  vendorHash = "sha256-F+geyscJcGpKfLPEVT42RO5G/2QMx5tK43URT/9y5Pk=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Faillint is a simple Go linter that fails when a specific set of import paths or exported path's functions, constant, vars or types are used.";
    homepage = "https://github.com/fatih/faillint";
    license = licenses.bsd3;
    maintainers = lib.optional (lib.maintainers ? simonswine) lib.maintainers.simonswine;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
