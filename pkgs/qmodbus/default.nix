{
  source,
  stdenv,
  qt5,
}:
stdenv.mkDerivation {
  inherit (source) pname version src;

  buildInputs = [qt5.qtbase];

  nativeBuildInputs = [qt5.wrapQtAppsHook];

  buildPhase = ''
    qmake -makefile qmodbus.pro
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    ls -lah .
    mv qmodbus $out/bin/

    mkdir -p $out/share/{icons,applications}

    mv qmodbus.desktop $out/share/applications/
    mv data/logo.{png,svg} $out/share/icons/
    chmod +x $out/share/applications/qmodbus.desktop

    substituteInPlace $out/share/applications/qmodbus.desktop \
      --replace "/usr/share/qmodbus/build/qmodbus" "$out/bin/qmodbus" \
      --replace "/usr/share/qmodbus/data/logo.png" "$out/share/icons/logo.png"
  '';
}
