{ rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  name = "gimli-addr2line";
  version = "0.24.2";

  src = fetchFromGitHub {
    owner = "gimli-rs";
    repo = "addr2line";
    rev = version;
    hash = "sha256-l3WZkXnb2zG8FetVBRhYnpMMTONfZvUstbSwdz2V3KA=";
  };

  buildFeatures = [ "bin" ];
  doCheck = false;

  cargoHash = "sha256-3TqdfHHXHabyiMNkLxoo+JJlzwbF9kS6chRje6Lck0U=";

  meta = {
    description = "TODO";
    homepage = "TODO";
    #license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
