{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland/v0.26.0";
    hyprland.inputs.nixpkgs.follows = "unstable";

    hyprland-contrib.url = "github:hyprwm/contrib/v0.1";
    hyprland-contrib.inputs.nixpkgs.follows = "unstable";

    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpaper.inputs.nixpkgs.follows = "unstable";

    eww.url = "github:elkowar/eww";
    eww.inputs.nixpkgs.follows = "unstable";
    eww.inputs.rust-overlay.follows = "rust-overlay";

    devenv.url = "github:cachix/devenv/latest";
    devenv.inputs.nixpkgs.follows = "unstable";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    nixos-mailserver.inputs.nixpkgs.follows = "unstable";

    vinix.url = "github:Stupremee/vinix";
    vinix.inputs.nixpkgs.follows = "nixpkgs";
    vinix.inputs.rust-overlay.follows = "rust-overlay";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "unstable";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self inputs;} {
      imports = [
        ./shell.nix
        ./systems
        ./pkgs
        ./nixos/deploy.nix
      ];

      systems = ["x86_64-linux" "aarch64-darwin"];
    };
}
