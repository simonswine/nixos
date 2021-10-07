{ pkgs, makeWrapper, stdenv, lib }:

stdenv.mkDerivation {
  name = "prometheus-node-exporter-restic";

  src = [
    ./restic.sh
  ];

  unpackPhase = ''
    for srcFile in $src; do
      cp $srcFile $(stripHash $srcFile)
    done
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin/
    cp restic.sh $out/bin/node-exporter-restic
    chmod +x $out/bin/node-exporter-restic
    wrapProgram $out/bin/node-exporter-restic \
      --set PATH ${lib.makeBinPath [ pkgs.gawk pkgs.findutils ]}
  '';

  meta = {
    description = "A textfile exporter script for restic snapshots.";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.simonswine ];
  };
}
