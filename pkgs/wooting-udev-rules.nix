{ writeText, lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "wooting-udev-rules";
  version = "2021-11-26";

  src = writeText "wooting-udev.rules" ''
# Wooting Lekker
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1210", MODE:="0660", GROUP="input"
SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1210", MODE:="0660", GROUP="input"
# Wooting Lekker Alt-gamepad mode
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1211", MODE:="0660", GROUP="input"
SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1211", MODE:="0660", GROUP="input"
# Wooting Lekker 2nd Alt-gamepad mode
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1212", MODE:="0660", GROUP="input"
SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="1212", MODE:="0660", GROUP="input"

# Wooting Lekker update mode  
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", ATTRS{idProduct}=="121f", MODE:="0660", GROUP="input"
  '';

  dontUnpack = true;

  installPhase = ''
    install -Dpm644 $src $out/lib/udev/rules.d/wooting.rules
  '';
}
