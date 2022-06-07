{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , unstable
    , flake-parts
    , deploy-rs
    }: flake-parts.lib.mkFlake { inherit self; } {
      imports = [
        ./shell.nix
        ./systems
        ./nixos/deploy.nix
      ];

      systems = [ "x86_64-linux" "aarch64-darwin" ];
    };
}
