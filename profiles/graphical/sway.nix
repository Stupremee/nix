{ pkgs, lib, ... }: {
  programs.sway = {
    enable = true;
    extraPackages = [ ];
  };

  environment.systemPackages = with pkgs; [ libsForQt5.qt5.qtwayland ];
}
