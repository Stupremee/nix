{ ... }:
{
  perSystem =
    {
      pkgs,
      pkgs-unstable,
      lib,
      ...
    }:
    let
      inherit (builtins)
        listToAttrs
        attrNames
        attrValues
        readDir
        elem
        ;
      inherit (lib) filterAttrs;

      useUnstable = [
        "caddy"
      ];
    in
    {
      packages = listToAttrs (
        map (x: {
          name = x;
          value =
            let
              p = if elem x useUnstable then pkgs-unstable else pkgs;
            in
            p.callPackage ./${x} { };
        }) (attrNames (filterAttrs (_: ty: ty == "directory") (readDir ./.)))
      );
    };
}
