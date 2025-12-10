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

  gitIdentity = pkgs.writeShellScriptBin "git-identity" (readFile ./git-identity.sh);
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

    programs.bat.enable = true;

    programs.delta = {
      enable = true;
    };

    programs.git = {
      enable = true;

      signing.key = mkDefault "D54A1CD51376F46C";
      signing.signByDefault = true;

      settings = {
        alias = {
          st = "status";
          co = "switch";
          df = "diff";
          lg = "log --oneline";
          p = "push";
          c = "commit";
          a = "add";
        };

        user = {
          name = mkDefault "Justus K";
          email = mkDefault "justus.k@protonmail.com";
        };

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

      lfs.enable = true;
    };
  };
}
