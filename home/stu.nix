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
    zulip
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
  xdg.configFile."nixpkgs/overlays/rust.nix".text = ''
    import (builtins.fetchTarball {
      url = https://github.com/oxalica/rust-overlay/archive/master.tar.gz;
    })
  '';

  # Install rust analyzer overlay
  xdg.configFile."nixpkgs/overlays/rust-analyzer.nix".text = ''
    import (builtins.fetchTarball {
      url = https://github.com/Stupremee/rust-analyzer-overlay/archive/main.tar.gz;
    })
  '';

  home.stateVersion = "20.09";
}
