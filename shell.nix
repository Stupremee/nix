{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShellNoCC {
      name = "flk";

      buildInputs = with pkgs; [
        treefmt
        nixpkgs-fmt
      ];
    };
  };
}
