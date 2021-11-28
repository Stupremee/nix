{ appimageTools
, fetchurl
, lib
, gsettings-desktop-schemas
, gtk3
, libxkbfile
, udev
, wooting-udev-rules
}:
let
  pname = "wootility-lekker";
  version = "4.2.2";
in
appimageTools.wrapType2 rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://s3.eu-west-2.amazonaws.com/wooting-update/wootility-lekker-linux-beta/wootility-lekker-beta-${version}-beta.AppImage";
    sha256 = "sha256-p1P+UhvQuzvZj1Y26NiYNIg6+WVSdba2JvisvpLvLrk=";
  };

  profile = ''
    export LC_ALL=C.UTF-8
    export XDG_DATA_DIRS="${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS"
  '';

  multiPkgs = extraPkgs;
  extraPkgs =
    pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs) ++ ([
      udev
      wooting-udev-rules
      libxkbfile
    ]);

  extraInstallCommands = "mv $out/bin/{${name},${pname}}";
}
