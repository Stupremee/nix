{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.graphical.alacritty;
in
{
  options.modules.graphical.alacritty = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    theme = mkOption {
      type = types.path;
    };
  };

  config =
    let
      theme = import cfg.theme { inherit pkgs; };

      keybind = key: mods: action: { inherit key mods action; };
      viKeybind = key: mods: action: {
        inherit key mods action;
        mode = "Vi";
      };
    in
    mkIf cfg.enable {
      home.sessionVariables = { TERMINAL = "alacritty"; };

      programs.alacritty = {
        enable = true;
        package = pkgs.alacritty;
        settings = {
          colors = theme.alacritty.colors;

          env.TERM = "xterm-256color";

          font = {
            size = 9;
            normal.family = "FiraCode Nerd Font";
            bold = {
              family = "monospace";
              style = "Bold";
            };
            italic = {
              family = "monospace";
              style = "Italic";
            };
          };

          background_opacity = 1;
          cursor.style = "Block";
          cursor.vi_mode_style = "Block";

          live_config_reload = true;

          shell.program = "zsh";

          key_bindings = [
            (keybind "V" "Alt" "Paste")
            (keybind "C" "Alt" "Copy")

            (keybind "Key0" "Control" "ResetFontSize")

            (keybind "Equals" "Control" "IncreaseFontSize")
            (keybind "Plus" "Control" "IncreaseFontSize")
            (keybind "Minus" "Control" "DecreaseFontSize")

            # Vi Mode
            (viKeybind "V" "Shift|Alt" "ScrollToBottom")
            (keybind "V" "Shift|Alt" "ToggleViMode")
          ];
        };
      };
    };
}
