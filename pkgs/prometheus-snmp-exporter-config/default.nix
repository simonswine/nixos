{ stdenv, prometheus-snmp-exporter }:

stdenv.mkDerivation {
  name = "prometheus-snmp-exporter-config";

  phases = [
    "installPhase"
    "fixupPhase"
  ];
  nativeBuildInputs = [ prometheus-snmp-exporter ];

  installPhase = ''
    cp ${./generator.yaml} generator.yml
    ${prometheus-snmp-exporter}/bin/generator generate
    mkdir -p $out/share/
    cp snmp.yml $out/share/
  '';
}
