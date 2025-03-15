{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.alacritty;

  keybind = key: mods: action: { inherit key mods action; };

  viKeybind = key: mods: action: {
    inherit key mods action;
    mode = "Vi";
  };
in
{
  options.my.alacritty.enable = mkEnableOption "Enable alacritty terminal";

  config = mkIf cfg.enable {
    home.sessionVariables.TERMINAL = "${config.programs.alacritty.package}/bin/alacritty";

    programs.alacritty = {
      enable = true;

      settings = {
        env.TERM = "xterm-256color";

        window.opacity = 1;

        cursor.style = "Block";
        cursor.vi_mode_style = "Block";

        keyboard.bindings = [
          (keybind "V" "Alt" "Paste")
          (keybind "C" "Alt" "Copy")

          (viKeybind "V" "Shift|Alt" "ScrollToBottom")
          (keybind "V" "Shift|Alt" "ToggleViMode")
        ];

        font = {
          size = 9;
          normal.family = "monospace";

          bold = {
            family = "monospace";
            style = "Bold";
          };

          italic = {
            family = "monospace";
            style = "Italic";
          };
        };
      };
    };
  };
}
