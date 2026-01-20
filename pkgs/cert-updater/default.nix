{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "cert-updater";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "cert-updater";
    rev = "${version}";
    sha256 = "b1FOdRHG7KinnUfU3gyHIOuodNd14txxZA2yo5D1Avw=";
  };

  vendorHash = "sha256-DYVavTvDSEBvIFDWi6NIWMq1EceVsaplpuz0PyvIyHk=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "A small utility to sync kubernetes certificate secrets.";
    homepage = "https://github.com/simonswine/cert-updater";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.unix;
  };
}
