{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    # Unstable required because hyprland needs wayland 1.21
    hyprland.inputs.nixpkgs.follows = "unstable";

    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , unstable
    , home-manager
    , flake-parts
    , deploy-rs
    , agenix
    , hyprland
    , hyprland-contrib
    }: flake-parts.lib.mkFlake { inherit self; } {
      imports = [
        ./shell.nix
        ./systems
        ./nixos/deploy.nix
      ];

      systems = [ "x86_64-linux" "aarch64-darwin" ];
    };
}
