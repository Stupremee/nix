{
  source,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  inherit (source) pname version src;

  format = "pyproject";

  nativeBuildInputs = [
  ];

  propagatedBuildInputs = with python3Packages; [
    hatchling
    hatch-vcs
    pillow
    appdirs
    pyqrcode
    python-barcode
    pyusb
    pyqt6
  ];
}
