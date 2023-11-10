{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    devShells.default = pkgs.mkShellNoCC {
      name = "flk";

      buildInputs = with pkgs; [
        home-manager

        treefmt
        alejandra
        shfmt
        stylua
        inputs'.unstable.legacyPackages.nvfetcher

        inputs'.deploy-rs.packages.deploy-rs
        inputs'.agenix.packages.agenix
        inputs'.vinix.packages.default
        age-plugin-yubikey
      ];
    };
  };
}
