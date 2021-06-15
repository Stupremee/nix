final: prev: {
  starship = prev.callPackage ./starship.nix { };

  vimPlugins = prev.vimPlugins // (prev.recurseIntoAttrs (prev.callPackage ./vimPlugins.nix { }));
}
