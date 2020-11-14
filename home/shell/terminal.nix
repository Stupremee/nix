{ pkgs, ... }:
let
  loadYaml = path: (pkgs.trivial.importJSON (yamlToJson path));

  yamlToJson = path:
    pkgs.runCommand { nativeBuildInputs = [ pkgs.yq-go ]; }
    "${pkgs.yq-go}/bin/yq r -j ${path} > $out";

  keybind = key: mods: action: { inherit key mods action; };
  viKeybind = key: mods: action: {
    inherit key mods action;
    mode = "Vi";
  };
in {
  programs.alacritty = {
    enable = true;
    settings = {

      font = {
        size = 14;
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

      background_opacity = 1;
      cursor.style = "Block";
      cursor.vi_mode_style = "Block";

      live_config_reload = true;

      shell.program = "/run/current-system/sw/bin/zsh";

      mouse.url.launcher.program = "xdg-open";

      key_bindings = [
        keybind
        "V"
        "Alt"
        "Paste"
        keybind
        "C"
        "Alt"
        "Copy"

        keybind
        "Key0"
        "Controll"
        "ResetFontSize"

        keybind
        "Equals"
        "Control"
        "IncreaseFontSize"
        keybind
        "Add"
        "Control"
        "IncreaseFontSize"

        keybind
        "Subtract"
        "Control"
        "DecreaseFontSize"
        keybind
        "Minus"
        "Control"
        "DecreaseFontSize"

        # Vi Mode
        viKeybind
        "V"
        "Shift|Alt"
        "ScrolllToBottom"
        keybind
        "V"
        "Shift|Alt"
        "ToggleViMode"
      ];
    } // loadYaml ./nord-theme.yml;

  };
}
