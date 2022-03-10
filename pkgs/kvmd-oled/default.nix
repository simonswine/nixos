{ lib, fetchFromGitHub, gcc, python3Packages }:

let
  rpi-gpio = python3Packages.buildPythonPackage rec {
    pname = "rpi-gpio";
    version = "0.7.1";
    src = python3Packages.fetchPypi rec {
      inherit version;
      pname = "RPi.GPIO";
      sha256 = "zWHEsDw3tiu6SlrP6phidJwzxhjgKV5+kKpHE/s3O3A=";
    };

    doCheck = false;
  };

  luma-core = python3Packages.buildPythonPackage rec {
    pname = "python-luma-core";
    version = "2.3.2";

    propagatedBuildInputs = with python3Packages; [
      smbus2
      cbor2
      rpi-gpio
      deprecated
      spidev
      pyftdi
      pillow
    ];

    src = fetchFromGitHub rec {
      owner = "rm-hull";
      repo = "luma.core";
      rev = "${version}";
      sha256 = "eaDFTt3qR35Rg7jRbL4ZODRz+rpQgmd3gGxd0lsXhvs=";
    };

    doCheck = false;

    meta = {
      homepage = "https://github.com/pytoolz/toolz/";
      description = "List processing tools and functional utilities";
    };
  };

  luma-oled = python3Packages.buildPythonPackage rec {
    pname = "python-luma-oled";
    version = "3.8.1";

    propagatedBuildInputs = with python3Packages; [
      luma-core
      pkgs.proggyfonts
    ];

    src = fetchFromGitHub rec {
      owner = "rm-hull";
      repo = "luma.oled";
      rev = "${version}";
      sha256 = "bC7ASYdyEFTsBZwepZDVCSnYawmhWN50sYQuq3JZ85Q=";
    };

    doCheck = false;

    meta = {
      homepage = "https://github.com/pytoolz/toolz/";
      description = "List processing tools and functional utilities";
    };
  };

in
python3Packages.buildPythonApplication rec {
  pname = "kvmd-oled";
  version = "0.12";

  propagatedBuildInputs = with python3Packages; [
    psutil
    netifaces
    pillow
    luma-oled
  ];

  src = fetchFromGitHub {
    owner = "pikvm";
    repo = "packages";
    rev = "22f3ee4c62d098185c94fb84b4815a43c0e486be";
    sha256 = "chS3pr01OXrGEbILd/OyH4R5Z5RDdzRt0y0SCyCPAp8=";
  };

  format = "other";

  buildPhase = ''
    true
  '';

  installPhase = ''
    mkdir -p $out/bin/ $out/share/images/
    cp packages/kvmd-oled/pikvm.ppm packages/kvmd-oled/hello.ppm $out/share/images/
    cp packages/kvmd-oled/kvmd-oled.py $out/bin/kvmd-oled
    wrapPythonPrograms
  '';

  meta = with lib; {
    homepage = "https://www.pikvm.org";
    description = "Main daemon for PiKVM - A IP-KVM based on Raspberry Pi";
    maintainers = with maintainers; [ simonswine ];
    license = licenses.gpl3;
  };
}
