{ config, theme, ... }:
let
  keybind = key: mods: action: { inherit key mods action; };

  viKeybind = key: mods: action: {
    inherit key mods action;
    mode = "Vi";
  };
in
{
  home.sessionVariables.TERMINAL = "${config.programs.alacritty.package}/bin/alacritty";
  programs.alacritty = {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";

      window.opacity = 0.9;

      cursor.style = "Block";
      cursor.vi_mode_style = "Block";

      key_bindings = [
        (keybind "V" "Alt" "Paste")
        (keybind "C" "Alt" "Copy")

        (viKeybind "V" "Shift|Alt" "ScrollToBottom")
        (keybind "V" "Shift|Alt" "ToggleViMode")
      ];

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

      colors = {
        primary = {
          background = theme.base;
          foreground = theme.text;
          dim_foreground = theme.text;
          bright_foreground = theme.text;
        };

        cursor = {
          text = theme.base;
          cursor = theme.rosewater;
        };

        vi_mode_cursor = {
          text = theme.base;
          cursor = theme.lavender;
        };

        search = {
          matches = {
            foreground = theme.base;
            background = theme.subtext1;
          };

          focused_match = {
            foreground = theme.base;
            background = theme.green;
          };

          footer_bar = {
            foreground = theme.base;
            background = theme.subtext0;
          };
        };

        hints = {
          start = {
            foreground = theme.base;
            background = theme.yellow;
          };

          end = {
            foreground = theme.base;
            background = theme.subtext0;
          };
        };

        selection = {
          text = theme.base;
          background = theme.rosewater;
        };

        normal = {
          black = theme.surface1;
          red = theme.red;
          green = theme.green;
          yellow = theme.yellow;
          blue = theme.blue;
          magenta = theme.pink;
          cyan = theme.teal;
          white = theme.subtext1;
        };

        bright = {
          black = theme.surface2;
          red = theme.red;
          green = theme.green;
          yellow = theme.yellow;
          blue = theme.blue;
          magenta = theme.pink;
          cyan = theme.teal;
          white = theme.subtext0;
        };

        dim = {
          black = theme.surface1;
          red = theme.red;
          green = theme.green;
          yellow = theme.yellow;
          blue = theme.blue;
          magenta = theme.pink;
          cyan = theme.teal;
          white = theme.subtext1;
        };

        indexed_colors = [
          { index = 16; color = theme.peach; }
          { index = 17; color = theme.rosewater; }
        ];
      };
    };
  };
}
