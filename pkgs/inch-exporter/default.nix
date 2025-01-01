{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "inch-exporter";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "inch-exporter";
    rev = "v${version}";
    hash = "sha256-1Xl8ukEKnZuzKsvhRfvO1b3B4knSb31znUsOk1CjkXM=";
  };

  vendorHash = "sha256-ws321AvIOMFyxt7L+l5RcHw38G+84aquSvB+3GSM4pE=";

  subPackages = [ "." ];

  meta = with lib; {
    homepage = "https://github.com/simonswine/inch-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.unix;
  };
}

