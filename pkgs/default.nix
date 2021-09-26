final: prev: {
  vimPlugins = prev.vimPlugins // (prev.recurseIntoAttrs (prev.callPackage ./vimPlugins.nix { }));

  cargo-smart-release = prev.callPackage ./cargo-smart-release.nix { };

  ghidra = prev.callPackage ./ghidra.nix { };

  distant = prev.callPackage ./distant.nix { };

  nb = prev.callPackage ./nb.nix { };

  comma = prev.callPackage ./comma { };

  blocky = prev.callPackage ./blocky.nix {
    buildGoModule = prev.buildGoModule.override { go = prev.go_1_17; };
  };

  personalScripts = prev.callPackage ./scripts { };
}
