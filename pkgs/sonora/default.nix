{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  mold,
  makeWrapper,
  alsa-lib,
  dbus,
  fontconfig,
  freetype,
  sqlite,
  libxcb,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  wayland,
  vulkan-loader,
  webkitgtk_4_1,
  glib-networking,
  gst_all_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sonora";
  version = "0.42.1";

  src = fetchFromGitHub {
    owner = "sonorahq";
    repo = "sonora";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d2GSNySpFxTjAb9fDBEAyQdZUVV8q+Iibotr0e/J+8w=";
  };

  cargoHash = "sha256-jmFe8HnVGR557j+2piGVnMBR9saPQjCDFOd8WBT1fGs=";

  # Upstream's Cargo configuration passes -fuse-ld=mold on Linux.
  nativeBuildInputs = [
    pkg-config
    cmake
    mold
    makeWrapper
  ];
  buildInputs = [
    alsa-lib
    dbus
    fontconfig
    freetype
    sqlite
    libxcb
    libx11
    libxkbcommon
  ];

  postInstall = ''
    install -Dm444 assets/linux/sonora.desktop $out/share/applications/sonora.desktop
    install -Dm444 assets/linux/sonora.svg $out/share/icons/hicolor/scalable/apps/sonora.svg
    for icon in assets/linux/icons/hicolor/*/apps/sonora.png; do
      size="$(basename "$(dirname "$(dirname "$icon")")")"
      install -Dm444 "$icon" "$out/share/icons/hicolor/$size/apps/sonora.png"
    done
    wrapProgram $out/bin/sonora \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          vulkan-loader
          wayland
          libxkbcommon
          libxcb
          libx11
          libxcursor
          libxi
          fontconfig
          freetype
          alsa-lib
          dbus
          sqlite
          webkitgtk_4_1
        ]
      } \
      --prefix GIO_EXTRA_MODULES : ${glib-networking}/lib/gio/modules \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (
          with gst_all_1;
          [
            gstreamer
            gst-plugins-base
            gst-plugins-good
          ]
        )
      }
  '';

  meta = {
    description = "Native music streaming client";
    homepage = "https://github.com/sonorahq/sonora";
    license = lib.licenses.gpl3Plus;
    mainProgram = "sonora";
    platforms = lib.platforms.linux;
  };
})
