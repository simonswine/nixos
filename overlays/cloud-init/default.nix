self: super:
{
  cloud-init = super.cloud-init.overrideAttrs (
    old: rec {
      version = "21.1";
      src = super.fetchurl {
        url = "https://launchpad.net/cloud-init/trunk/${version}/+download/cloud-init-${version}.tar.gz";
        sha256 = "0000000000000000000000000000000000000000000000000000";
      };
    }
  );
}
