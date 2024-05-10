{
  lib,
  pkgs,
  unstable-pkgs,
  theme,
  ...
}: let
  inherit (lib) mkDefault;
  gitIdentity =
    pkgs.writeShellScriptBin "git-identity" (builtins.readFile ./git-identity);
in {
  home.packages = with unstable-pkgs; [gh fzf gitIdentity git-credential-oauth];

  programs.git = {
    enable = true;
    package = unstable-pkgs.gitAndTools.gitFull;

    userName = mkDefault "Justus K";
    userEmail = mkDefault "justus.k@protonmail.com";

    signing.key = mkDefault "D54A1CD51376F46C";
    signing.signByDefault = true;

    delta = {
      enable = true;
      package = unstable-pkgs.delta;

      options = {
        features = "interactive";
        light = theme.light;
      };
    };

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

      user.useConfigOnly = true;

      # the `work` identity
      user.work.name = "Justus Kliem";
      user.work.email = "justus.kliem@ekd-solar.de";
      user.work.signingKey = "31AC6529";

      # the `personal` identity
      user.personal.name = "Justus K";
      user.personal.email = "justus.k@protonmail.com";
      user.personal.signingKey = "D54A1CD51376F46C";

      # core.pager = delta;
      # interactive.diffFilter = "${delta} --color-only --features=interactive";

      credential.helper = [
        "cache --timeout 7200"
        "oauth"
      ];

      "credential \"https://git.mainframe.lan\"" = {
        oauthClientId = "a4792ccc-144e-407e-86c9-5e7d8d9c3269";
        oauthAuthURL = "/login/oauth/authorize";
        oauthTokenURL = "/login/oauth/access_token";
      };
    };
  };
}
