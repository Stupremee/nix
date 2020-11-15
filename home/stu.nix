{ pkgs, ... }: {
  imports = [
    ./dev
    ./shell

    ./gpg.nix
    ./git.nix
  ];

  home.packages = [
    discord
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
