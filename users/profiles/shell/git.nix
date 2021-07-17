{ pkgs, config, lib, ... }: {
  programs.git = {
    enable = true;

    userName = "Justus K";
    userEmail = "justus.k@protonmail.com";

    signing.key = "D54A1CD51376F46C";
    signing.signByDefault = true;

    aliases = {
      st = "status";
      co = "checkout";
      df = "diff";
      lg = "log --oneline";
      p = "push";
      c = "commit";
      a = "add";
    };

    lfs.enable = true;

    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
    };

    delta.enable = true;
  };

  home.packages = with pkgs; [ gh ];
}
