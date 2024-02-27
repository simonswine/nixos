{ pyroscope }:

pyroscope.overrideAttrs (_: rec {
  pname = "profilecli";
  subPackages = [ "cmd/profilecli" ];
})

