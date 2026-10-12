{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.muse;
  varlock = pkgs.callPackage ../../../packages/varlock { };
  defaultModel = "muse-wonder-full-1.0-contributor";
  model = order: id: label: {
    model_id = id;
    provider_id = "meta";
    profile_id = "tbh";
    display_label = label;
    visibility = "visible";
    display_order = order;
    is_default = id == defaultModel;
    context_limit = 1007997;
    output_limit = 128000;
    description = "Your content, including inter-session messages, may be used for product improvement.";
  };
  settings = pkgs.writeText "muse-cliproxy-settings.json" (
    builtins.toJSON {
      provider = "meta";
      model = defaultModel;
      endpoint_transport = {
        base_url = "https://cliproxy.jukl.dev/v1";
        auth = "bearer";
      };
      model_catalog = [
        (model 0 "muse-wonder-1.0-contributor" "Muse Wonder 1.0 Contributor")
        (model 1 defaultModel "Muse Wonder Full 1.0 Contributor")
        (model 2 "muse-spark-1.3-contributor" "Muse Spark 1.3 Contributor")
        (model 3 "muse-spark-1.2-contributor" "Muse Spark 1.2 Contributor")
      ];
      contributor_mode_enabled = true;
      contributor_mode_disclosure_acknowledged = true;
    }
  );
in
{
  options.my.muse.enable = lib.mkEnableOption "Muse Code through CLIProxyAPI with Contributor models";

  config = lib.mkIf cfg.enable {
    home.packages = [ varlock ];

    xdg.configFile = {
      "muse/cliproxy/read-key.py".source = ./read-key.py;
      "muse/cliproxy/profile.json".source = settings;
      "muse/cliproxy/.env.schema".text = ''
        # @defaultSensitive=true @defaultRequired=true
        # ---
        # Reuse the existing CLIProxyAPI client credential at startup.
        # @sensitive @required
        META_API_KEY=exec("${pkgs.python3}/bin/python3 ${./read-key.py}")
      '';
    };

    home.file.".local/bin/muse" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail
        exec ${pkgs.coreutils}/bin/env -u META_API_KEY ${varlock}/bin/varlock run \
          --inject vars --skip-cache \
          --path ${lib.escapeShellArg "${config.xdg.configHome}/muse/cliproxy/.env.schema"} \
          -- ${lib.escapeShellArg "${config.home.homeDirectory}/.local/bin/muse-upstream"} "$@"
      '';
    };

    # Muse writes settings.json itself, so merge only Nix-owned settings.
    home.activation.museSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.python3}/bin/python3 ${./merge-settings.py} \
        ${settings} ${lib.escapeShellArg "${config.xdg.configHome}/muse/settings.json"}
    '';
  };
}
