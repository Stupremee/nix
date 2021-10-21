# Packages that are imported inside this file,
# will be pulled from the `unstable` nixpkgs.
pkgs: final: prev: {
  inherit (pkgs)
    vimPlugins
    manix
    rust-analyzer
    firefox-wayland
    alacritty
    tailscale
    zellij
    starship
    direnv
    dunst
    zls
    ncspot
    discord;
}
