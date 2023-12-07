{ lib
, buildGoModule
, fetchFromGitHub
, zfs
, makeWrapper
}:

buildGoModule rec {
  pname = "zfs-event-exporter";
  version = "15c214a249db90ab43c932606e5cdf1240622e07";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "zfs-event-exporter";
    rev = "${version}";
    hash = "sha256-qpyJKlB5/kNghdnlXl+/NIO3RjSDIBXVkDCouXBgI9A=";
  };

  vendorHash = "sha256-foQ9Era09LF3cla2XfV6+kI0PO4qzBc8Es9yU/1Gx2I=";

  nativeBuildInputs = [ makeWrapper ];

  fixupPhase = ''
    mv $out/bin/zfs-event-exporter $out/bin/node-exporter-zfs
    wrapProgram $out/bin/node-exporter-zfs \
      --set PATH ${lib.makeBinPath [ zfs ]}
  '';

  meta = with lib; {
    description = "A node exporter exporter script for zfs metrics.";
    homepage = "https://github.com/xperimental/flowercare-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
