{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "fluidcad";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "Fluid-CAD";
    repo = "FluidCAD";
    rev = "v${version}";
    hash = "sha256-NjR0TV7vx7oVrk43ZNvRdIteBaDdKnOtMM+hM0jJYQg=";
  };

  npmDepsHash = "sha256-gK0/yNtr3+uKiziowOHp13ajJLOA5aOHe1qYCY+58X4=";

  meta = {
    description = "Parametric CAD modeling tool – write 3D models in JavaScript with real-time 3D preview";
    homepage = "https://fluidcad.io";
    license = lib.licenses.lgpl21;
    mainProgram = "fluidcad";
  };
}
