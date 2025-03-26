{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  packages = self + /packages;

  mkPkgs =
    system:
    import inputs.nixpkgs-unstable {
      inherit system;
    };
in
self: _: {
  unstable = mkPkgs self.system;
  caddy = self.unstable.callPackage "${packages}/caddy" { };
}
