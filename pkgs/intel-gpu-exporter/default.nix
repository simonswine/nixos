{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "intel-gpu-exporter";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "intel-gpu-exporter";
    rev = "ec6dfe4";
    sha256 = "0rqq87pf3l73pdgiqn6qgzc926v2vncxi3z3k7b53snj7jw32z1x";
  };

  vendorSha256 = "0isp0pawhwxabl9cbb5p6wmx2ky4hbkhm0ywk1zc6b4vi9zrcyvn";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Export Intel's GPU stats as Prometheus metrics.";
    homepage = "https://github.com/simonswine/intel-gpu-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
