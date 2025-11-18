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
    };
in
self: _: {
  unstable = mkPkgs self.system;
  caddy = self.unstable.callPackage "${packages}/caddy" { };
  nushell = self.nushell.overrideAttrs (_: {
    doCheck = false;
    dontCargoCheck = true;
    checkPhase = ''
      echo "Skipping tests with dontCargoCheck"
    '';
  });
}
