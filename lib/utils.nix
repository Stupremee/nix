{ lib }:
let
  inherit (builtins) attrNames;

  importPkgs = { pkgs, system, overlays }:
    import pkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };
in {
  pkgSet = { stable, unstable, overlays, system }: {
    stable = pkgImport {
      inherit system overlays;
      pkgs = stable;
    };

    unstable = pkgImport {
      inherit system overlays;
      pkgs = unstable;
    };
  };

  overlayPaths = let
    overlayDir = ../overlays;
    fullPath = name: overlayDir + "/${name}";
  in map fullPath (attrNames (readDir overlayDir));
}
