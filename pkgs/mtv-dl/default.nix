{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

let
  typer-config = python3Packages.buildPythonPackage rec {
    pname = "typer-config";
    version = "1.4.2";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "maxb2";
      repo = "typer-config";
      rev = version;
      sha256 = "sha256-ncbEUbDizw7THqLy6GUWI2p5a0K5Q8HoZotfmr95Hs4=";
    };
    build-system = with python3Packages; [
      poetry-core
    ];

    dependencies = with python3Packages; [
      typer
    ];
  };

in

python3Packages.buildPythonApplication {
  pname = "mtv-dl";
  version = "0.27.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fnep";
    repo = "mtv_dl";
    rev = "60e331cdd402513330f26713a6e6a5e451482838";
    sha256 = "sha256-nKYtquWvOf01mkJt16dJQKkYR9+fLNC+bfsuNIK/qQ8=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  postPatch = ''
    # Replace the entire [build-system] section to use setuptools
    sed -i '/\[build-system\]/,/^$/c\
    [build-system]\
    requires = ["setuptools", "wheel"]\
    build-backend = "setuptools.build_meta"' pyproject.toml

    # Remove repository field that's incompatible with setuptools
    sed -i '/repository = /d' pyproject.toml || true

  '';

  dependencies = with python3Packages; [
    iso8601
    durationpy
    pyyaml
    beautifulsoup4
    certifi
    click
    colorama
    ijson
    typer
    typer-config
  ];

  # Dependencies are very fresh upstream, relax them a bit
  pythonRelaxDeps = [
    "beautifulsoup4"
    "durationpy"
    "certifi"
    "ijson"
    "typer"
  ];

  meta = {
    description = "A command line tool to download videos from public broadcasting services in Germany.";
    mainProgram = "mtv_dl";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ simonswine ];
  };
}
