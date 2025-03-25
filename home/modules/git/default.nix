{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  inherit (builtins) readFile;

  cfg = config.my.git;

  gitIdentity = pkgs.writeShellScriptBin "git-identity" (readFile ./git-identity);
in
{
  options.my.git.enable = mkEnableOption "Enable proper Git in shell";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        gh
        fzf
        gitIdentity
        git-credential-oauth
      ];

      shellAliases = {
        g = "git";
      };
    };

    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;

      userName = mkDefault "Justus K";
      userEmail = mkDefault "justus.k@protonmail.com";

      signing.key = mkDefault "D54A1CD51376F46C";
      signing.signByDefault = true;

      delta = {
        enable = true;
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

        user = {
          useConfigOnly = true;

          # the `work` identity
          work = {
            name = "Justus Kliem";
            email = "justus.kliem@ekd-solar.de";
            signingKey = "31AC6529";
          };

          # the `personal` identity
          personal = {
            name = "Justus K";
            email = "justus.k@protonmail.com";
            signingKey = "D54A1CD51376F46C";
          };
        };

        # core.pager = delta;
        # interactive.diffFilter = "${delta} --color-only --features=interactive";

        credential.helper = [
          "cache --timeout 7200"
          "oauth"
        ];
      };
    };
  };
}
