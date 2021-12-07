{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "docker-machine-driver-hetzner";
  version = "3.5.0";

  src = fetchFromGitHub rec {
    owner = "JonasProgrammer";
    repo = "docker-machine-driver-hetzner";
    rev = version;
    sha256 = "Fnfh8q619jzT+mzyh8RGjzaS0qRpXqz7bWm3wwVcFzw=";
  };

  vendorSha256 = "0rKGTO66JVGN/77oZODvtVR8hZBd2JEtt/tjy9/oe8M=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "This library adds the support for creating Docker machines hosted on the Hetzner Cloud.";
    homepage = "https://github.com/JonasProgrammer/docker-machine-driver-hetzner";
    license = licenses.mit;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux;
  };
}
