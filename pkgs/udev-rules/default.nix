{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "custom-udev-rules";
  version = "latest";

  src = lib.sourceFilesBySuffices ./. [ ".rules" ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/lib/udev/rules.d/
    install -Dpm644 $src/* $out/lib/udev/rules.d/
  '';
}
