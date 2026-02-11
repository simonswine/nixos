{
  stdenv,
  net-snmp,
  buildGoModule,
  fetchFromGitHub,
}:

let

  prometheus-snmp-exporter = buildGoModule rec {
    pname = "snmp_exporter";
    version = "git-2026-02-06";

    src = fetchFromGitHub {
      owner = "prometheus";
      repo = "snmp_exporter";
      rev = "337d524003d1932b7e95ba05fb15ef212533ac90";
      sha256 = "sha256-7DCdG7lCAYbxbQwLgcN7/QcN/twrUmc0b6ihrf5T2cA=";
    };

    vendorHash = "sha256-GNdfCmPtsJa2l47LjFZG3us+PRNQfcb65jIfEjCS3Jc=";

    buildInputs = [ net-snmp ];

    doCheck = false;

  };
in

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
