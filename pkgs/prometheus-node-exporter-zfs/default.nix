{ lib
, buildGoModule
, fetchFromGitHub
, zfs
, makeWrapper
}:

buildGoModule rec {
  pname = "zfs-event-exporter";
  version = "2ef7737";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "zfs-event-exporter";
    rev = "${version}";
    hash = "sha256-Vwl2+WawcEeEJsT32xDsy4bubA1HVwCdBnXDufVLpEo=";
  };

  vendorHash = "sha256-KX4CaoDXkhkbkEHgA66JY8FX26XNLvnw2eJg5bfBZtM=";

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
