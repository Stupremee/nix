{ pkgs, ... }: {
  imports = [ ./common.nix ];

  home-manager.users.stu = {
    imports = [
      ./profiles/graphical/bspwm
      ./profiles/graphical/alacritty

      ./profiles/shell/tmux.nix
    ];

    home.packages = with pkgs; [
      firefox
      spotify
      discord
      distant
      obsidian
      teams
      libreoffice
      signal-desktop
    ];
  };
}
