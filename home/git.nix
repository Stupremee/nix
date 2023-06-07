{
  unstable-pkgs,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  home.packages = with unstable-pkgs; [delta gh];

  programs.git = {
    enable = true;
    package = unstable-pkgs.gitAndTools.gitFull;

    userName = mkDefault "Justus K";
    userEmail = mkDefault "justus.k@protonmail.com";

    signing.key = mkDefault "D54A1CD51376F46C";
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
