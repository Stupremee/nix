{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  packages = self + /packages;
in
self: prev: {
  caddy = prev.callPackage "${packages}/caddy" { };
  sunspecModbusServer = prev.callPackage "${packages}/sunspec-modbus-server" { };
  direnv = prev.direnv.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace GNUmakefile --replace-fail " -linkmode=external" ""
    '';
  });
}
