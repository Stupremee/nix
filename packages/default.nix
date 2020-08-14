[
  (self: super: with super; {
    my = {
      spotifyd = (callPackage ./spotifyd.nix {});
    };

    unstable = import <nixos-unstable> { inherit config; };
  })
]
