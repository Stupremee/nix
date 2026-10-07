{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.git;
in
{
  options.my.git.enable = mkEnableOption "Enable proper Git in shell";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        gh
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

        # core.pager = delta;
        # interactive.diffFilter = "${delta} --color-only --features=interactive";

        credential = {
          helper = [
            "cache --timeout 7200"
            "oauth"
          ];

          # Authenticate GitHub via the gh CLI. The empty entry clears the
          # helpers inherited from the section above so only gh is consulted.
          "https://github.com".helper = [
            ""
            "!${getExe pkgs.gh} auth git-credential"
          ];
        };
      };

      lfs.enable = true;
    };
  };
}
