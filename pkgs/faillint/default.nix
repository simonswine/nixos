{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "faillint";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "fatih";
    repo = "faillint";
    rev = "v${version}";
    hash = "sha256-uUpg7gjYnyOBzA984jF/dZ4gQwZ29EZzvHhLxJPAOG4=";
  };

  vendorHash = "sha256-s6TG6kp64LYGPNynoBNbJvbDmT+9XgaWZewTTsi/NXs=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Faillint is a simple Go linter that fails when a specific set of import paths or exported path's functions, constant, vars or types are used.";
    homepage = "https://github.com/fatih/faillint";
    license = licenses.bsd3;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
