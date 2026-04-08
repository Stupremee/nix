{ inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];

  perSystem =
    { self', system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = { };
      };
      # Enables 'nix run' to activate.
      packages.default = self'.packages.activate;

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
