{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  python3,
  usbutils,
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    beautifulsoup4
    click
    furl
    questionary
    requests
    rich
  ]);
in
stdenvNoCC.mkDerivation rec {
  pname = "openttmgr";
  version = "0-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "themoses";
    repo = "openttmgr";
    rev = "3ff397a30f7fd3e0a2fa4d55832d78018af4e3f8";
    hash = "sha256-24X7Nydec0i5iH1GTENJhGswJIbYPDSosjXoP9oJogM=";
  };

  nativeBuildInputs = [
    makeWrapper
    pythonEnv
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 openttmgr.py $out/bin/openttmgr
    patchShebangs $out/bin/openttmgr

    # The tool shells out to `lsusb` to detect a connected tiptoi pen.
    wrapProgram $out/bin/openttmgr \
      --prefix PATH : ${lib.makeBinPath [ usbutils ]}

    runHook postInstall
  '';

  meta = {
    description = "Open source tool to manage tiptoi products by Ravensburger";
    homepage = "https://github.com/themoses/openttmgr";
    license = lib.licenses.gpl3Only;
    mainProgram = "openttmgr";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ simonswine ];
  };
}
