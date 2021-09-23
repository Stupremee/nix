{ pkgs, ... }: {
  imports = [ ./common.nix ];

  home-manager.users.stu = {
    imports = [
      ./profiles/graphical/bspwm
      ./profiles/graphical/alacritty
    ];

    home.packages = with pkgs; [ firefox spotify discord distant obsidian teams ];
  };
}
