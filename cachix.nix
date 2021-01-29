{ ... }: {
  nix = {
    binaryCaches =
      [ "https://cache.nixos.org/" "https://nixpkgs-wayland.cachix.org" ];

    binaryCachePublicKeys = [
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };
}
