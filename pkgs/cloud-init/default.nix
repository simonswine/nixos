{ lib, python3Packages, fetchurl, cloud-utils }:
let version = "21.1";

in
python3Packages.buildPythonApplication {
  pname = "cloud-init";
  inherit version;
  namePrefix = "";

  src = fetchurl {
    url = "https://launchpad.net/cloud-init/trunk/${version}/+download/cloud-init-${version}.tar.gz";
    sha256 = "0wl5k6wbzd5kj4h1pvz0jznc6xgnl2nklc023f9mrhhdp7g29d4c";
  };

  patches = [ ./add-nixos-support.patch ];
  prePatch = ''
    patchShebangs ./tools

    substituteInPlace setup.py \
      --replace /usr $out \
      --replace /etc $out/etc \
      --replace /lib/systemd $out/lib/systemd \
      --replace 'self.init_system = ""' 'self.init_system = "systemd"'

    substituteInPlace cloudinit/config/cc_growpart.py \
      --replace 'util.subp(["growpart"' 'util.subp(["${cloud-utils}/bin/growpart"'
  '';

  propagatedBuildInputs = with python3Packages; [
    #cheetah
    jinja2
    prettytable
    oauthlib
    pyserial
    configobj
    pyyaml
    requests
    jsonpatch
    jsonschema
  ];

  checkInputs = with python3Packages; [ contextlib2 httpretty mock unittest2 ];

  doCheck = false;

  meta = {
    homepage = "https://cloudinit.readthedocs.org";
    description = "Provides configuration and customization of cloud instance";
    maintainers = [ lib.maintainers.madjar lib.maintainers.phile314 ];
    platforms = lib.platforms.all;
  };
}
