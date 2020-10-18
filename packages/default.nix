[
  (self: super: with super; {
    my = {
      spotifyd = (callPackage ./spotifyd.nix {});
      ddlog = (callPackage ./ddlog.nix {});
    };

    unstable = import <nixos-unstable> { inherit config; };
    discord = super.discord.overrideAttrs (_: {
      src = builtins.fetchTarball https://discord.com/api/download?platform=linux&format=tar.gz;
    });
  })
]
