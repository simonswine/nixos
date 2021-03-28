{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "zrepl";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "zrepl";
    repo = "zrepl";
    rev = "v${version}";
    sha256 = "06ppr0c2skzr6hiilfsb3izq6wwhmmi4swj7r3yij9wjc7q0pmf2";
  };

  vendorSha256 = "007zagqya6mj76ifws8ydq8jb7ak0mjff5ard32jmapwn38mgc70";

  subPackages = [ "." ];

  meta = with lib; {
    description = "zrepl is a one-stop, integrated solution for ZFS replication.";
    homepage = "https://zrepl.github.io/";
    license = licenses.mit;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
