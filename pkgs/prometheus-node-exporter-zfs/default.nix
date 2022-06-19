{ pkgs, makeWrapper, stdenv, fetchFromGitHub, python3Packages, lib }:

with python3Packages;

let
  _prometheus_client = buildPythonApplication rec {
    pname = "prometheus_client";
    version = "0.11.0";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "Oouq3my4C8/kMpfjPnYj8xGNZg1BOHWTdY4vseoXOoY=";
    };

    doCheck = false;
  };

in

buildPythonApplication rec {
  pname = "prometheus-node-exporter-zfs";
  version = "fb831ed78c7c4321b1d897ddc906e274f79e4e30";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "node-exporter-textfile-collector-scripts";
    rev = "${version}";
    sha256 = "42Z+S/ww/VndbzlQwgWgIEfCRrhE1zcvzf8YRdHMjIU=";
  };

  pythonPath = [ _prometheus_client ];

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = pythonPath;

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin/
    cp zfs.py $out/bin/node-exporter-zfs
    chmod +x $out/bin/node-exporter-zfs
    wrapProgram $out/bin/node-exporter-zfs \
      --set PATH ${lib.makeBinPath [ pkgs.zfs ]}
  '';

  meta = {
    homepage = https://github.com/simonswine/node-exporter-textfile-collector-scripts/blob/fb831ed78c7c4321b1d897ddc906e274f79e4e30/zfs.py;
    description = "A textfile exporter script for zfs metrics.";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.simonswine ];
  };
}
