{ inputs, self, ... }:
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

        check = {
          description = "Run nix flake check";
          exec = "nix flake check";
        };

        activate =
        let
          machines = builtins.concatStringsSep " " (lib.attrNames self.nixosConfigurations);
        in {
          description = "Used to remotely activate machines";
          exec = ''
            nix run .#activate -- "$(${pkgs.gum}/bin/gum choose ${machines})"
          '';
        };
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.mission-control.devShell ];

        nativeBuildInputs = with pkgs; [
          config.agenix-rekey.package
          age-plugin-yubikey
        ];
      };
    };
}
