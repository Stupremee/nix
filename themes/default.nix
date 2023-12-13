{lib, ...}: let
  inherit (builtins) readDir attrNames listToAttrs map;
  inherit (lib) filterAttrs;

  isDir = _: ty: ty == "directory";

  themeFiles = attrNames (filterAttrs isDir (readDir ./.));

  themes = listToAttrs (map
    (name: rec {
      inherit name;
      value =
        (import ./${name})
        // {
          inherit name;
          wallpaper = ./wall.png;
        };
    })
    themeFiles);
in
  themes
