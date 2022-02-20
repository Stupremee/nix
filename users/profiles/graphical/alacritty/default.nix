{ pkgs, lib, config, ... }:
let
  loadYaml = path: (yamlToJson path);
  yamlToJson = path:
    pkgs.runCommand "yaml2json" { nativeBuildInputs = [ pkgs.yq-go ]; }
      "${pkgs.yq-go}/bin/yq e -j ${path} > $out";
  colors = builtins.fromJSON (builtins.readFile (loadYaml ./theme.yaml));

  keybind = key: mods: action: { inherit key mods action; };
  viKeybind = key: mods: action: {
    inherit key mods action;
    mode = "Vi";
  };
in
{
  home.sessionVariables = { TERMINAL = "alacritty"; };

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = {
      inherit colors;

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

      window.opacity = 1;
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
}
