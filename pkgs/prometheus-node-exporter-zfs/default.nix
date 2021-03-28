{ pkgs, makeWrapper, stdenv, fetchFromGitHub, python3Packages, lib }:

python3Packages.buildPythonApplication rec {
  pname = "prometheus-node-exporter-zfs";
  version = "1ae4b227044e633e00f440ec676c53c8e3315016";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "node-exporter-textfile-collector-scripts";
    rev = "${version}";
    sha256 = "0lxjblz32sxlkfhdsgcy6h6fhac0pmci9q0bp4iak9p6nnvk89bw";
  };

  pythonPath = with python3Packages; [ prometheus_client ];

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
    homepage = https://github.com/simonswine/node-exporter-textfile-collector-scripts/blob/1ae4b227044e633e00f440ec676c53c8e3315016/zfs.py;
    description = "A textfile exporter script for zfs metrics.";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.simonswine ];
  };
}
