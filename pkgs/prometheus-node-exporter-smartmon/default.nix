{ pkgs, makeWrapper, stdenv, fetchFromGitHub, python3Packages, lib }:

stdenv.mkDerivation rec {
  name = "prometheus-node-exporter-smartmon-${version}";
  version = "7d89f195cb3871e62f09e85433ea7fd7d310df5b";

  src = fetchFromGitHub {
    owner = "prometheus-community";
    repo = "node-exporter-textfile-collector-scripts";
    rev = "${version}";
    sha256 = "1g0hafzz2v80a1rbcrbn2sw5wzb9bkyz5sr57bip4cd485zz10hm";
  };

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ python3Packages.python ];

  installPhase = ''
    mkdir -p $out/bin/
    cp smartmon.py $out/bin/node-exporter-smartmon
    chmod +x $out/bin/node-exporter-smartmon
    wrapProgram $out/bin/node-exporter-smartmon \
      --set PATH ${lib.makeBinPath [ pkgs.smartmontools ]}
  '';

  meta = {
    homepage = https://github.com//blob/master/smartmon.py;
    description = "A textfile exporter script for smart hard disk metrics.";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.simonswine ];
  };
}
