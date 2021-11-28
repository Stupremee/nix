{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption types literalExpression mkIf mapAttrsToList makeBinPath;
  inherit (builtins) fromTOML attrValues;

  cfg = config.programs.helix;

  mkTomlOption = t: d: mkOption {
    type = types.nullOr t;
    default = null;
    description = d;
  };

  editorConfigType = with types; {
    scrolloff = mkTomlOption int "Number of lines of padding around the edge of the screen when scrolling.";
    mouse = mkTomlOption bool "Enable mouse mode.";
    middle-click-paste = mkTomlOption bool "Middle click paste support.";
    scroll-lines = mkTomlOption int "Number of lines to scroll per scroll wheel step.";
    shell = mkTomlOption (listOf string) "Shell to use when running external commands.";
    line-number = mkTomlOption (enum [ "absolute" "relative" ]) "Line number display.";
    smart-case = mkTomlOption bool "Enable smart case regex searching.";
    auto-pairs = mkTomlOption bool "Enable automatic insertion of pairs to parenthese, brackets, etc.";
    auto-completion = mkTomlOption bool "Enable automatic pop up of auto-completion.";
    idle-timeout = mkTomlOption int ''
      Time in milliseconds since last keypress before idle timers trigger.
      Used for autocompletion, set to 0 for instant.
    '';
    completion-trigger-len = mkTomlOption int "The min-length of word under cursor to trigger autocompletion.";
    auto-info = mkTomlOption bool "Whether to display infoboxes.";

    filepicker = {
      hidden = mkTomlOption bool "Enables ignoring hidden files.";
      parents = mkTomlOption bool "Enables reading ignore files from parent directories.";
      ignore = mkTomlOption bool "Enables reading `.ignore` files.";
      git-ignore = mkTomlOption bool "Enables reading `.gitignore` files.";
      git-global = mkTomlOption bool "Enables reading global `.gitignore` file.";
      git-exclude = mkTomlOption bool "Enables reading `.git/info/exclude` files.";
      max-depth = mkTomlOption int "Set with an integer value for maximum depth to recurse.";
    };
  };

  keymapOption = mode: mkOption {
    type = types.attrs;
    default = { };
    example = {
      "a" = "move_char_left";
      "C-S-esc" = "extend_line";
    };
    description = "Key remappings in ${mode} mode.";
  };
in
{
  options.programs.helix = {
    enable = mkEnableOption "Helix-Editor";

    package = mkOption {
      type = types.package;
      default = pkgs.helix;
      defaultText = literalExpression "pkgs.helix";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = "[ pkgs.rust-analyzer ]";
      description = "Extra packages available to helix.";
    };

    defaultEditor = mkOption {
      type = types.bool;
      default = false;
      description = ''
        When enabled, installs helix and configures helix to be the default editor
        using the $EDITOR environment variable.
      '';
    };

    config = with types; {
      theme = mkTomlOption string "Set the theme to use.";
      editor = editorConfigType;
      lsp = {
        display-messages = mkTomlOption bool "Enables display of all LSP messages in status line.";
      };
    };

    keys = with types; {
      normal = keymapOption "normal";
      insert = keymapOption "insert";
    };

    language = mkOption {
      default = { };
      type = with types; attrsOf attrs;
      description = "Configure different language settings.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Custom lines to append to Helix's configuration file.
        Must be valid TOML.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      let
        binPath = makeBinPath cfg.extraPackages;
      in
      [
        (cfg.package.overrideAttrs (_: {
          postFixup = ''
            wrapProgram $out/bin/hx --set HELIX_RUNTIME $out/lib/runtime --suffix PATH : ${binPath}
          '';
        }))
      ];

    xdg.configFile."helix/languages.toml".source =
      let
        langs = mapAttrsToList (name: val: { inherit name; } // val) cfg.language;
        config = { language = langs; };

        jsonConf = pkgs.writeText "languages.json" (builtins.toJSON config);
      in
      pkgs.runCommandNoCC "languages.toml" { } ''
        ${pkgs.yj}/bin/yj -jt < ${jsonConf} > $out
      '';

    xdg.configFile."helix/config.toml".source =
      let
        config = cfg.config // { keys = cfg.keys; } // (fromTOML cfg.extraConfig);

        jsonConf = pkgs.writeText "config.json" (builtins.toJSON config);
      in
      pkgs.runCommandNoCC "config.toml" { } ''
        ${pkgs.yj}/bin/yj -jt < ${jsonConf} > $out
      '';
  };
}
