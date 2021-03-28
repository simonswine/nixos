{ stdenv, rustPlatform, fetchFromGitHub, perl }:

rustPlatform.buildRustPackage rec {
  pname = "tickrs";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "tarkah";
    repo = pname;
    rev = "v${version}";
    sha256 = "03n6yssmnf6vhcxxir5qzr51pxqh3rd437vwv6z7yzj2wfih3srq";
  };

  cargoSha256 = "08zjg9dm6lv9gxm9lhc3vj1187vrmvwlchc0y7fx2wj6yvh1yvrx";

  nativeBuildInputs = [ perl ];

  meta = with stdenv.lib; {
    description = "Realtime ticker data in your terminal";
    homepage = "https://github.com/tarkah/tickrs";
    license = licenses.mit;
    maintainers = with maintainers; [ simonswine ];
  };
}
