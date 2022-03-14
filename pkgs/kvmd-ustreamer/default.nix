{ lib, stdenv, stdenvNoCC, fetchFromGitHub, libbsd, libevent, libjpeg }:

let

  libraspberrypi = stdenvNoCC.mkDerivation rec {
    # NOTE: this should be updated with linux_rpi
    pname = "raspberrypi-firmware";
    version = "1.20210805";

    src = fetchFromGitHub {
      owner = "raspberrypi";
      repo = "firmware";
      rev = version;
      sha256 = "1nndhjv4il42yw3pq8ni3r4nlp1m0r229fadrf4f9v51mgcg11i1";
    };

    installPhase = ''
      mkdir -p $out/include
      cp -R opt/vc/include/* $out/include/
    '';

    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    meta = with lib; {
      description = "Firmware for the Raspberry Pi board";
      homepage = "https://github.com/raspberrypi/firmware";
      license = licenses.unfreeRedistributableFirmware; # See https://github.com/raspberrypi/firmware/blob/master/boot/LICENCE.broadcom
      maintainers = with maintainers; [ dezgeg ];
    };
  };
in

stdenv.mkDerivation rec {
  pname = "ustreamer";
  version = "5.0";

  src = fetchFromGitHub {
    owner = "pikvm";
    repo = "ustreamer";
    rev = "v${version}";
    sha256 = "BpDoeP/NxJBShVdUPviPpyh4ELWha4R679cwcvcjxTQ=";
  };

  buildInputs = [ libbsd libevent libjpeg libraspberrypi ];

  makeFlags = [
    "WITH_OMX=1"
    # Not neccessary "WITH_JANUS=1"
  ];

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ustreamer $out/bin/
  '';

  meta = with lib; {
    homepage = "https://github.com/pikvm/ustreamer";
    description = "Lightweight and fast MJPG-HTTP streamer";
    longDescription = ''
      µStreamer is a lightweight and very quick server to stream MJPG video from
      any V4L2 device to the net. All new browsers have native support of this
      video format, as well as most video players such as mplayer, VLC etc.
      µStreamer is a part of the Pi-KVM project designed to stream VGA and HDMI
      screencast hardware data with the highest resolution and FPS possible.
    '';
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ tfc ];
    platforms = platforms.linux;
  };
}

