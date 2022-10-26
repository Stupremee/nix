{ lib, ... }:
let
  inherit (builtins) filter readDir readFile attrNames listToAttrs map fromJSON;
  inherit (lib) hasSuffix removeSuffix;

  isJson = n: (hasSuffix ".json" n);

  themeFiles = filter isJson (attrNames (readDir ./.));

  themes = listToAttrs (map
    (file: rec {
      name = removeSuffix ".json" file;
      value = fromJSON (readFile "${./.}/${name}.json");
    })
    themeFiles);
in
themes
