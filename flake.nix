{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos.url = "github:NixOS/nixpkgs/nixos-21.11";

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    inputs@{ self
    , nixos
    , unstable
    , flake-utils
    , devshell
    }:
    let
      importPkgs = pkgs: overlays: system:
        import pkgs {
          inherit system overlays;

          config = {
            allowUnfree = false;
            allowUnfreePredicate = pkg: builtins.elem (nixos.lib.getName pkg) (import ../pkgs/allowUnfree.nix);
          };
        };
    in
    { } // flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
    let
      pkgs = importPkgs unstable [ devshell.overlay ] system;
    in
    {
      # devshell configuration on each system
      devShell = pkgs.devshell.mkShell {
        name = "flk";
        imports = [ (pkgs.devshell.importTOML ./shell.toml) ];
      };
    }
    );
}
