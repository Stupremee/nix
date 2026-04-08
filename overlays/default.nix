{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  packages = self + /packages;

  mkPkgs =
    system:
    import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (_: prev: {
          direnv = prev.direnv.overrideAttrs (_: {
            postPatch = ''
              substituteInPlace GNUmakefile --replace-fail " -linkmode=external" ""
            '';
          });
        })
      ];
    };
in
self: prev: {
  unstable = mkPkgs self.system;
  caddy = self.unstable.callPackage "${packages}/caddy" { };
  direnv = prev.direnv.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace GNUmakefile --replace-fail " -linkmode=external" ""
    '';
  });
}
