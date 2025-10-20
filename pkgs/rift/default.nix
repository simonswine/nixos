{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, iconv
}:

rustPlatform.buildRustPackage {
  pname = "rift";
  version = "git-2025-10-13";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift";
    rev = "62adb05a2fe86004d56f638c69762166e91265fb";
    hash = "sha256-nQwHDZ/772t+Xqd6AK5mthvSWHqYzx7Utuv9GHe0lyU=";
  };

  cargoHash = "sha256-41QUCNIsbg1mYzJgaMUPKY1jfn9m6a5XzGz9dqYS3eE=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    iconv
  ];

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "rift";
  };
}
