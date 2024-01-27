{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "intel-gpu-exporter";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "intel-gpu-exporter";
    rev = "98b453b79fd93d7b5e5fadc6de7b76df407f0c2d";
    sha256 = "EyTPHKMIY5AD0KBhVZLA8K0q6ZXfazXKsmLEmr8t/bE=";
  };

  vendorHash = "sha256-SR57IEuqD/2y2i39MYnGQ2+O0YHEb7roKZ+vJc/vUoc=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Export Intel's GPU stats as Prometheus metrics.";
    homepage = "https://github.com/simonswine/intel-gpu-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
