{ pkgs, ... }: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    extraConfig = {
      pull.rebase = true;
    };

    userName = "Justus K";
    userEmail = "justus.k@protonmail.com";

    signing.key = "D54A1CD51376F46C";
    signing.signByDefault = true;

    aliases = {
      a = "add -p";
      co = "checkout";
      c = "commit";
      p = "push";
      df = "diff";

      # reset
      soft = "reset --soft";
      hard = "reset --hard";

      # logging
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      plog = "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
      tlog = "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
      rank = "shortlog -sn --no-merges";
    };

    delta.enable = true;
  };

  home.packages = with pkgs; [ gh ];
}
