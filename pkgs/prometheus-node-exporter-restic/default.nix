{ pkgs, stdenv, lib }:

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

  installPhase = ''
    mkdir -p $out/bin/
    cp restic.sh $out/bin/node-exporter-restic
    chmod +x $out/bin/node-exporter-restic
  '';

  meta = {
    description = "A textfile exporter script for restic snapshots.";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.simonswine ];
  };
}
