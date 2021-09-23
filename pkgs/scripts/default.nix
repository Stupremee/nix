{ runCommand
, lib
, stdenv
, bash
, makeWrapper

  # canoncam
, gphoto2
, ffmpeg
}:
let
  inherit (builtins) filterSource baseNameOf;
  inherit (lib) makeBinPath;

  # List of dependencie that are availabe
  # in the scripts execution environment
  deps = [ gphoto2 ffmpeg ];
in
stdenv.mkDerivation {
  name = "scripts";

  buildInputs = [ bash ];
  nativeBuildInputs = [ makeWrapper ];

  src = filterSource (p: ty: baseNameOf p != "default.nix") ./.;

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    install -D * $out/bin

    for file in $out/bin/*; do
      chmod +x $file
      wrapProgram $file --set PATH "${makeBinPath deps}"
    done
  '';
}
