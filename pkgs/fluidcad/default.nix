{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "fluidcad";
  version = "0.0.51";

  src = fetchFromGitHub {
    owner = "Fluid-CAD";
    repo = "FluidCAD";
    rev = "v${version}";
    hash = "sha256-7MZbCQYz+1Ocy32UUb1mGxhKY0671zci5vkenZe1+iU=";
  };

  npmDepsHash = "sha256-PuotzIIHksWhdrRSdBWHGklyUfDReDhiZbnEQAG/Bsg=";

  meta = {
    description = "Parametric CAD modeling tool – write 3D models in JavaScript with real-time 3D preview";
    homepage = "https://fluidcad.io";
    license = lib.licenses.mit;
    mainProgram = "fluidcad";
  };
}
