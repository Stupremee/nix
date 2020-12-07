{ pkgs, ... }: {
  imports = [
    ./shell
    ./editors
    ./desktop
    ./browsers

    ./gpg.nix
    ./git.nix
  ];

  xdg.enable = true;
  home.enableDebugInfo = true;
  home.packages = with pkgs; [
    unstable.discord-canary
    spotify

    # TODO: Add desktop entries
    zathura
    mpv
    feh
    libreoffice

    # Gaming 
    steam
    lutris

    # Man pages
    man-db
    man-pages
    posix_man_pages
  ];

  # Alllow unfree packages.
  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  # Install rust overlay
  xdg.configFile."nixpkgs/overlays/rust-overlay.nix".source =
    ../overlays/rust-overlay.nix;

  home.stateVersion = "20.09";
}
