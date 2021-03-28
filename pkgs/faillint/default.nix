{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "ticker";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "fatih";
    repo = "faillint";
    rev = "v${version}";
    sha256 = "0viqq29w8jvqpirldx3n0r1j17kmgwqy4z0grj0j77yq13p60jmr";
  };

  vendorSha256 = "0yrmpz44w4zccnb0cpmx7ycw7xi6bc9s19yw7h3bdq3s9bmcd95k";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Faillint is a simple Go linter that fails when a specific set of import paths or exported path's functions, constant, vars or types are used.";
    homepage = "https://github.com/fatih/faillint";
    license = licenses.bsd3;
    maintainers = with maintainers; [ simonswine ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
