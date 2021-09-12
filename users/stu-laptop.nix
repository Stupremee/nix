{ pkgs, ... }: {
  imports = [ ./common.nix ];

  home-manager.users.stu = {
    imports = [
      ./profiles/graphical/sway
      ./profiles/graphical/alacritty
      ./profiles/graphical/gtk.nix
    ];

    home.packages = with pkgs; [ spotify libreoffice firefox-wayland ];
  };
}
