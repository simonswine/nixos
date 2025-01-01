{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "sonnenbatterie-exporter";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "sonnenbatterie-exporter";
    rev = "v${version}";
    hash = "sha256-y5RpVgCoRZY59YRVspm5szndt30VGLrOl7emeU2ksGc=";
  };

  vendorHash = "sha256-PKdn+AhW9wIBgBN5uwtU41SgK1kD9d+B59cKPP7BGcs=";

  subPackages = [ "." ];

  meta = with lib; {
    homepage = "https://github.com/simonswine/sonnenbatterie-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.unix;
  };
}

