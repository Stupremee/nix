{ lib }:
let
  inherit (builtins) readDir baseNameOf;
  inherit (lib)
    hasSuffix recursiveUpdate listToAttrs attrNames removeSuffix filterAttrs
    mapAttrs' nameValuePair;

  mapFilterAttrs = seive: f: attrs: filterAttrs seive (mapAttrs' f attrs);

  importPkgs = pkgs: overlays: system:
    import pkgs {
      inherit system overlays;
      config = {
        allowUnfree = false;
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) (import ../pkgs/allowUnfree.nix);
        permittedInsecurePackages = import ../pkgs/allowInsecure.nix;
      };
    };

  # Takes a list of values and a function `f`.
  # Maps every element inside the list using `f`,
  # and then converts the returned set `{ name = ...; value = ...; }`
  # into a set.
  genAttrs = values: f: listToAttrs (map f values);

  # Convert a list of file paths (like in `../modules/list.nix`)
  # to a map that maps from `file_name -> file_content`.
  importPaths = paths:
    genAttrs paths (path: {
      name = removeSuffix ".nix" (baseNameOf path);
      value = import path;
    });
in
{
  inherit importPaths importPkgs;

  overlayPaths =
    let
      overlayDir = ../overlays;
      fullPath = name: overlayDir + "/${name}";
    in
    map fullPath (attrNames (readDir overlayDir));

  nixosModules =
    let
      cachix = import ../cachix.nix;

      modules = importPaths (import ../modules/list.nix);

      profiles = importPaths (import ../profiles/list.nix);
    in
    recursiveUpdate modules { inherit profiles cachix; };

  recImport = { dir, _import ? base: import "${dir}/${base}.nix" }:
    mapFilterAttrs (_: v: v != null)
      (n: v:
        if n != "default.nix" && hasSuffix ".nix" n && v == "regular" then
          let name = removeSuffix ".nix" n; in nameValuePair (name) (_import name)
        else
          nameValuePair ("") (null))
      (readDir dir);

  keysFromGithub = { pkgs, username, sha256 ? lib.fakeSha256 }:
    (lib.splitString "\n" (builtins.readFile (pkgs.fetchurl {
      url = "https://github.com/${username}.keys";
      inherit sha256;
    })));
}
