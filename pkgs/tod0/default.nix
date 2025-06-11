{ lib
, python3Packages
, fetchFromGitHub
}:


python3Packages.buildPythonApplication rec {
  pname = "tod0";
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kiblee";
    repo = "tod0";
    rev = "v${version}";
    hash = "sha256-QojJXu7fnl7StCq6jPYZcbjTQbqTrxAq6mUSQhJryes=";
  };

  postUnpack = ''
    sed -i 's/"bs4"/"beautifulsoup4"/g' source/setup.py
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    prompt-toolkit
    requests
    requests-oauthlib
    pyyaml
    yaspin
    beautifulsoup4

  ];

  nativeCheckInputs = [
  ];

  meta = {
    changelog = "hhttps://github.com/kiblee/tod0/releases/tag/v${version}";
    description = "A Terminal Client for Microsoft To-Do ";
    homepage = "https://github.com/kiblee/tod0";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      simonswine
    ];
  };
}
