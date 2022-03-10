{ lib
, fetchFromGitHub
, makeWrapper
, glibc
, tesseract
, libraspberrypi
, janus-gateway
, ustreamer
, openssl
, bash
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "kvmd";
  version = "3.57";

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    pyyaml
    aiohttp
    aiofiles
    passlib
    python-periphery
    pyserial
    spidev
    setproctitle
    psutil
    netifaces
    systemd
    dbus-python
    pygments
    # TODO, needed for ipmi pyghmi
    pam
    pillow
    xlib
    hidapi
    glibc
    libgpiod
  ];

  src = fetchFromGitHub {
    owner = "pikvm";
    repo = "kvmd";
    rev = "v${version}";
    sha256 = "/3L/IVqUE7t0siq4rbc7OYM/4iaSPjEe54+getcMShY=";
  };

  postPatch = ''
    substituteInPlace kvmd/libc.py \
      --replace 'ctypes.util.find_library("c")' '"${glibc}/lib/libc.so.6"'

    substituteInPlace kvmd/apps/kvmd/tesseract.py \
      --replace 'ctypes.util.find_library("tesseract")' '"${tesseract}/lib/libtesseract.so.3"'

    substituteInPlace kvmd/apps/__init__.py  \
      --replace '"/bin/true"' '"/run/current-system/sw/bin/true"' \
      --replace '"/usr/bin/ip"' '"/run/current-system/sw/bin/ip"' \
      --replace '"/usr/sbin/iptables"' '"/run/current-system/sw/bin/iptables"' \
      --replace '"/usr/bin/systemd-run"' '"/run/current-system/sw/bin/systemd-run"' \
      --replace '"/usr/bin/systemctl"' '"/run/current-system/sw/bin/systemctl"' \
      --replace '"/opt/vc/bin/vcgencmd"' '"${libraspberrypi}/bin/vcgencmd"' \
      --replace '"/usr/bin/janus"' '"${janus-gateway}/bin/janus"' \
      --replace "/usr/share/kvmd/keymaps" "$out/share/keymaps" \
      --replace "\"/usr/share/kvmd/extras\"" "\"$out/share/extras\""

    substituteInPlace kvmd/plugins/msd/otg/__init__.py \
      --replace '"/usr/bin/sudo"' '"/run/wrappers/bin/sudo"'

    substituteInPlace configs/kvmd/main/v3-hdmi-rpi4.yaml \
      --replace '"/usr/bin/ustreamer"' '"${ustreamer}/bin/ustreamer"'

    substituteInPlace scripts/kvmd-gencert  \
      --replace '#!/bin/bash' '#!${bash}/bin/bash'

    for f in configs/nginx/*.conf extras/*/nginx.*.conf; do
      [[ $(basename $f) == "ssl.conf" ]] && continue
      sed -i "s#/usr/share/kvmd/extras#$out/share/extras#g" $f
      sed -i "s#/etc/kvmd/nginx#$out/share/configs/nginx#g" $f
      sed -i "s#/usr/share/kvmd/web#$out/share/web#g" $f
    done

  '';

  checkPhase = ''
    # TODO
  '';

  preInstall = ''
    mkdir -p "$out/share" "$out/share/configs" "$out/bin"
    cp -r {web,extras,contrib/keymaps} "$out/share"
    cp -r configs/kvmd configs/nginx "$out/share/configs"

    cp scripts/kvmd-gencert "$out/bin/"
    wrapProgram $out/bin/kvmd-gencert --prefix PATH : "${openssl}/bin"

    find "$out/share/web" -name '*.pug' -exec rm -f '{}' \;
  '';

  meta = with lib; {
    homepage = "https://www.pikvm.org";
    description = "Main daemon for PiKVM - A IP-KVM based on Raspberry Pi";
    maintainers = with maintainers; [ simonswine ];
    license = licenses.gpl3;
  };
}
