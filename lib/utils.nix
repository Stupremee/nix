{ lib }:
let
  inherit (builtins) attrNames;

  importPkgs = { pkgs, system, overlays }:
    import pkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

  genAttrs' = values: f: listToAttrs (map f values);
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

  modules = let
    cachix = import ../cachix.nix;
    modules = import ../modules/list.nix;
  in [ ];
}
