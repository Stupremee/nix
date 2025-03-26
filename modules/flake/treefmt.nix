{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";

        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rfc-style;
        };
        programs.shfmt.enable = true;

        settings.global.excludes = [
          ".envrc"
          ".editorconfig"
          "README.md"
          "LICENSE"
          "*.png"
          "packages/caddy/src/*"
          "secrets/*"
        ];
      };
    };
}
