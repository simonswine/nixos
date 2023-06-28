{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "modularise";
  version = "3e9a203";

  src = fetchFromGitHub {
    owner = "modularise";
    repo = "modularise";
    rev = "${version}";
    sha256 = "uER/QLao3ae1E9CqrtI7ndA+snsWW5SJr073QwJVVZc=";
  };

  vendorSha256 = "EzRuY7c3Sp0K5d1Xt7PCfJC4tuSBYZ+ZBhYpz/qy88g=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "modularise allows to split out go modules out of a parent project.";
    homepage = "https://github.com/modularise/modularise";
    license = licenses.mit;
    maintainers = with maintainers; [ simonswine ];
  };
}
