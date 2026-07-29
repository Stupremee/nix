{ inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];

  perSystem =
    {
      self',
      system,
      ...
    }:
    let
      pkgs = import inputs.nixpkgs {
        localSystem = system;
        config = { };
      };
    in
    {
      _module.args.pkgs = pkgs;
      # Enables 'nix run' to activate.
      packages.default = self'.packages.activate;
      packages.sunspecModbusServer = pkgs.callPackage ../../packages/sunspec-modbus-server { };

      nixos-unified = {
        primary-inputs = [
          "nixpkgs"
          "nixpkgs-unstable"
          "nixos-unified"
          "home-manager"
          "srvos"
          "nvf"
          "catppuccin"
          "impermanence"
        ];
      };
    };
}
