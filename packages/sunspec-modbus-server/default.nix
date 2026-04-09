{
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "sunspec-modbus-server";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    aiohttp
    pymodbus
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "sunspec_modbus_server"
  ];
}
