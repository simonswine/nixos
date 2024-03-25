{ lib
, fetchpatch
, fetchFromGitHub
, python3Packages
}:

with python3Packages;

buildPythonPackage rec {
  pname = "python-miio";
  version = "2024.02.16";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    rev = "35a8773f8cfdcb36e148b1944dff93726888cfe2";
    owner = "rytilahti";
    repo = "python-miio";
    hash = "sha256-tyv/N/7HgLhZxwuAhmnn0LbsYoQdlx4KDx/9VQx0fXg=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    android-backup
    appdirs
    attrs
    click
    construct
    croniter
    cryptography
    defusedxml
    micloud
    netifaces
    pytz
    pyyaml
    tqdm
    zeroconf
    pydantic
  ] ++ lib.optionals (pythonOlder "3.8") [
    importlib-metadata
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "miio"
  ];

  meta = with lib; {
    description = "Python library for interfacing with Xiaomi smart appliances";
    homepage = "https://github.com/rytilahti/python-miio";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ flyfloh ];
  };
}
