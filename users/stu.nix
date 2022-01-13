{ pkgs, ... }: {
  imports = [ ./common.nix ];

  home-manager.users.stu = {
    imports = [
      ./profiles/graphical/bspwm
      ./profiles/graphical/alacritty

      ./profiles/shell/tmux.nix
      ./profiles/editors/helix.nix
    ];

    home.packages = with pkgs; [
      firefox-bin
      spotify
      discord
      teams
      libreoffice
      signal-desktop
      ghidra
    ];
  };
}
