{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    userName = "Justus K";
    userEmail = "justus.k@protonmail.com";

    signing.key = "D54A1CD51376F46C";
    signing.signByDefault = true;

    aliases = {
      st = "status";
      co = "switch";
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
      push.autoSetupRemote = true;
    };

    delta.enable = true;
  };
}
