{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "docker-machine-driver-hetzner";
  version = "5.0.2";

  src = fetchFromGitHub rec {
    owner = "JonasProgrammer";
    repo = "docker-machine-driver-hetzner";
    rev = version;
    hash = "sha256-5mSlKedXSHNKnjfx+qVXplReSMZ5SKQBXt9Ct+ivgjk=";
  };

  vendorHash = "sha256-NIKjuC1Z18Sf6oCSXJ6L3a4sZ0ft/2SXwVf7elWB1kg=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "This library adds the support for creating Docker machines hosted on the Hetzner Cloud.";
    homepage = "https://github.com/JonasProgrammer/docker-machine-driver-hetzner";
    license = licenses.mit;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
