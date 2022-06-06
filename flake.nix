{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , unstable
    , flake-parts
    }: flake-parts.lib.mkFlake { inherit self; } {
      imports = [
        ./shell.nix
        ./systems
      ];

      systems = [ "x86_64-linux" "aarch64-darwin" ];
    };
  #let
  #importPkgs = pkgs: overlays: system:
  #import pkgs {
  #inherit system overlays;

  #config = {
  #allowUnfree = false;
  #allowUnfreePredicate = pkg: builtins.elem (nixos.lib.getName pkg) (import ../pkgs/allowUnfree.nix);
  #};
  #};
  #in
  #{ } // flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
  #let
  #pkgs = importPkgs unstable [ devshell.overlay ] system;
  #in
  #{
  ## devshell configuration on each system
  #devShell = pkgs.devshell.mkShell {
  #name = "flk";
  #imports = [ (pkgs.devshell.importTOML ./shell.toml) ];
  #};
  #}
  #);
}
