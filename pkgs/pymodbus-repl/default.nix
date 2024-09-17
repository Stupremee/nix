{
  source,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  inherit (source) pname version src;

  pyproject = true;
  build-system = [python3Packages.poetry-core];

  patches = [
    ./typer-version.patch
  ];

  dependencies = with python3Packages; [
    tabulate
    typer
    prompt-toolkit
    pygments
    tabulate
    aiohttp
    pymodbus
    pyserial
  ];
}
