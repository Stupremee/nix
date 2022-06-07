{
  perSystem = { pkgs, inputs', ... }: {
    devShells.default = pkgs.mkShellNoCC {
      name = "flk";

      buildInputs = with pkgs; [
        treefmt
        nixpkgs-fmt

        inputs'.deploy-rs.packages.deploy-rs
        inputs'.agenix.packages.agenix
        age-plugin-yubikey
      ];
    };
  };
}
