{ inputs, ... }:
{
  imports = [
    inputs.flake-root.flakeModule
    inputs.mission-control.flakeModule
    inputs.agenix-rekey.flakeModule
  ];

  perSystem =
    {
      pkgs,
      self',
      config,
      lib,
      ...
    }:
    {
      mission-control.scripts = {
        fmt = {
          description = "Format the whole project";
          exec = "${lib.getExe self'.formatter}";
        };

        activate = {
          description = "Used to remotely activate machines";
          exec = "nix run .#activate --";
        };
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.mission-control.devShell ];

        nativeBuildInputs = [ config.agenix-rekey.package ];
      };
    };
}
