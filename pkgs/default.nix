final: prev: {
  vimPlugins = prev.vimPlugins // (prev.recurseIntoAttrs (prev.callPackage ./vimPlugins.nix { }));
  cargo-smart-release = prev.callPackage ./cargo-smart-release.nix { };
  distant = prev.callPackage ./distant.nix { };
  nb = prev.callPackage ./nb.nix { };
  comma = prev.callPackage ./comma { };
}
