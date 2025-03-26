{ inputs, ... }:
{
  imports = [
    inputs.just-flake.flakeModule
    inputs.agenix-rekey.flakeModule
  ];

  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      just-flake.features = {
        flake = {
          enable = true;
          justfile = ''
            # Runs the activate script
            activate *args:
              nix run .#activate -- {{ args }}

            # Checks the flake
            check:
              nix flake check

            # Auto Format the whole tree
            fmt:
              nix fmt
          '';
        };
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [
          config.just-flake.outputs.devShell
        ];

        nativeBuildInputs = with pkgs; [
          config.agenix-rekey.package
          age-plugin-yubikey
        ];
      };
    };
}
