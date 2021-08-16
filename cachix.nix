{ ... }: {
  nix = {
    binaryCaches =
      [
        "https://cache.nixos.org/"
        "https://nixpkgs-wayland.cachix.org"
        "https://veloren-nix.cachix.org"
      ];

    binaryCachePublicKeys = [
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "veloren-nix.cachix.org-1:zokfKJqVsNV6kI/oJdLF6TYBdNPYGSb+diMVQPn/5Rc="
    ];
  };
}
