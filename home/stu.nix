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
    discord
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

  home.stateVersion = "20.09";
}
