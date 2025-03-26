{ inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];

  perSystem =
    { self', ... }:
    {
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
