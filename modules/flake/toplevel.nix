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
        overlays = [
          (_: prev: {
            nushell = prev.nushell.overrideAttrs (_: {
              doCheck = false; # Disable standard Nix check
              dontCargoCheck = true; # Disable cargoBuildHook check phase
              checkPhase = ''
                echo "Skipping tests with dontCargoCheck"
              '';
            });
          })
        ];
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
