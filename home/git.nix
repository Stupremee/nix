{unstable-pkgs, ...}: {
  home.packages = with unstable-pkgs; [delta gh];

  programs.git = {
    enable = true;
    package = unstable-pkgs.gitAndTools.gitFull;

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

    includes = [
      {
        condition = "gitdir:~/dev/work/";
        contents = {
          user = {
            name = "Justus Kliem";
            email = "justus.kliem@esyon.de";
          };
        };
      }
    ];

    lfs.enable = true;

    extraConfig = let
      delta = "${unstable-pkgs.delta}/bin/delta";
    in {
      pull.rebase = true;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;

      core.pager = delta;
      interactive.diffFilter = "${delta} --color-only --features=interactive";
    };
  };
}
