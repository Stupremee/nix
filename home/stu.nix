{ pkgs, ... }:
let
  installDesktopEntry = pkg: src: name:
    pkg.overrideAttrs (old: {
      postInstall = old.postInstall + ''
        install -Dm644 ${src} $out/share/applications/${name}
      '';
    });
in {
  imports = [
    ./shell
    ./editors
    ./desktop
    ./browsers

    ./gpg.nix
    ./git.nix
    ./docker.nix
  ];

  nix.trustedUsers = [ "root" "stu" ];

  xdg.enable = true;
  home.enableDebugInfo = true;
  home.packages = with pkgs; [
    discord
    spotify

    (installDesktopEntry zathura "data/org.pwmt.zathura.desktop.in"
      "org.pwmt.zathura.desktop")
    (installDesktopEntry mpv "etc/mpv.desktop" "mpv.desktop")
    # TODO: Add desktop entry for feh
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
