{ lib, python3Packages }:

let
  _durationpy = python3Packages.buildPythonApplication rec {
    pname = "durationpy";
    version = "0.5";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "XvlBa1J7UNci80ZVvs+3Xkkijrgvh7hV7RkRszFLVAg=";
    };
  };

  _rfc6266 = python3Packages.buildPythonApplication rec {
    pname = "rfc6266";
    version = "0.0.4";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "kjEWvXfPKDsWGoExOfUCLolOkdBAaGIIqjPrQ9sbdwM=";
    };
    propagatedBuildInputs = with python3Packages; [
      _lepl
    ];
    doCheck = false;
  };

  _rich = python3Packages.buildPythonApplication rec {
    pname = "rich";
    version = "2.2.6";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "3M9zWe0HVzaX4AamwWqBH6af6aDPRuhq2S1GFNmLEPE=";
    };
    propagatedBuildInputs = with python3Packages; [
      CommonMark
      colorama
      ipywidgets
      pprintpp
      pygments
      typing-extensions
    ];
  };

  _lepl = python3Packages.buildPythonApplication rec {
    pname = "LEPL";
    version = "5.1.3";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "qHFccJMINQzkr+1dUlaCZWiG04FBOH7IfURCHajUE5c=";
    };
  };

in

python3Packages.buildPythonApplication rec {
  pname = "mtv_dl";
  version = "0.18.1";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "Q46Uyl+Ud81nVOwyyqSsBo+9/PnUtEcWogwA2iMuq8k=";
  };

  propagatedBuildInputs = with python3Packages; [
    _durationpy
    _rich
    _rfc6266
    beautifulsoup4
    docopt
    iso8601
    pydash
    pyyaml
    tzlocal
  ];

  doCheck = false;

  meta = {
    homepage = "https://cloudinit.readthedocs.org";
    description = "Provides configuration and customization of cloud instance";
    maintainers = [ lib.maintainers.madjar lib.maintainers.phile314 ];
    platforms = lib.platforms.all;
  };
}
