{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "roc-vad";
  version = "0.0.4";

  src = fetchurl {
    url = "https://github.com/roc-streaming/roc-vad/releases/download/v${version}/roc-vad.tar.bz2";
    sha256 = "sha256-76OrOACS3lVBYNwCFAcC0rT5qi3bUDzyuQYYzbyV4po=";
  };

  dontBuild = true;
  dontFixup = true;

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    # Install CLI tool
    mkdir -p $out/bin
    cp usr/local/bin/roc-vad $out/bin/roc-vad
    chmod +x $out/bin/roc-vad

    # Install CoreAudio driver bundle
    mkdir -p $out/Library/Audio/Plug-Ins/HAL
    cp -R Library/Audio/Plug-Ins/HAL/roc_vad.driver $out/Library/Audio/Plug-Ins/HAL/

    runHook postInstall
  '';

  postInstall = ''
    cat << EOF

    ========================================
    roc-vad installation complete!
    ========================================

    The CLI tool is available at: $out/bin/roc-vad

    IMPORTANT: CoreAudio Driver Installation Required
    --------------------------------------------------
    The driver bundle has been installed to the Nix store, but macOS requires
    it to be in the system location. To complete the installation, run:

      sudo cp -R $out/Library/Audio/Plug-Ins/HAL/roc_vad.driver \\
                 /Library/Audio/Plug-Ins/HAL/

    After copying, restart coreaudiod:

      sudo killall coreaudiod

    To uninstall the driver later:

      sudo rm -rf /Library/Audio/Plug-Ins/HAL/roc_vad.driver
      sudo killall coreaudiod

    ========================================
    EOF
  '';

  meta = with lib; {
    description = "macOS Virtual Audio Device for real-time audio streaming";
    homepage = "https://github.com/roc-streaming/roc-vad";
    license = licenses.mpl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.darwin;
    mainProgram = "roc-vad";
  };
}
