# Packages that are imported inside this file,
# will be pulled from the `unstable` nixpkgs.
pkgs: final: prev: {
  inherit (pkgs) manix;

  starship =
    pkgs.starship.override { cargoBuildFlags = [ "--features rust-notify" ]; };
}
