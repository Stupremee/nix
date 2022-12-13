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
        nvfetcher

        inputs'.deploy-rs.packages.deploy-rs
        inputs'.nil.packages.nil
        inputs'.agenix.packages.agenix
        age-plugin-yubikey
      ];
    };
  };
}
