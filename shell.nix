{
  perSystem = { pkgs, inputs', ... }: {
    devShells.default = pkgs.mkShellNoCC {
      name = "flk";

      buildInputs = with pkgs; [
        home-manager

        treefmt
        nixpkgs-fmt
        shfmt

        inputs'.deploy-rs.packages.deploy-rs
        inputs'.agenix.packages.agenix
        age-plugin-yubikey
      ];
    };
  };
}
