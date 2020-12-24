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
    unstable.multimc

    # Man pages
    man-db
    man-pages
    posix_man_pages
  ];

  # Alllow unfree packages.
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
        unstable = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz") {};
      };
    }
  '';

  # Install rust overlay
  xdg.configFile."nixpkgs/overlays/rust-overlay.nix".source =
    ../overlays/rust-overlay.nix;

  home.stateVersion = "20.09";
}
