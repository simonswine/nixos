{
  lib,
  appimageTools,
  fetchurl,
  cacert,
  glib-networking,
}:
let
  pname = "bambu-studio";
  version = "02.08.02.61";
  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubuntu24.04-v${version}-20260820225108.AppImage";
    hash = "sha256-1QGxA/rFQkUT7A6Na8FF+zBxneLH2U1zINcjdAyBp/0=";
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  profile = ''
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    export CURL_CA_BUNDLE="$SSL_CERT_FILE"
    export GIO_MODULE_DIR="${glib-networking}/lib/gio/modules/"
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
  '';

  extraPkgs = pkgs: with pkgs; [
    cacert
    glib
    glib-networking
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    webkitgtk_4_1
  ];

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/BambuStudio.desktop $out/share/applications/bambu-studio.desktop
    substituteInPlace $out/share/applications/bambu-studio.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=bambu-studio'
    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "PC software for BambuLab's 3D printers";
    homepage = "https://github.com/bambulab/BambuStudio";
    changelog = "https://github.com/bambulab/BambuStudio/releases/tag/v${version}";
    license = with lib.licenses; [ agpl3Plus unfree ];
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
