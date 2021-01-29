{ pkgs, ... }:
let
  inherit (builtins) map;

  modifier = "Mod4";

  colors = {
    base00 = "#2E3440";
    base01 = "#3B4252";
    base02 = "#434C5E";
    base03 = "#4C566A";
    base04 = "#D8DEE9";
    base05 = "#E5E9F0";
    base06 = "#ECEFF4";
    base07 = "#8FBCBB";
    base08 = "#88C0D0";
    base09 = "#81A1C1";
    base0A = "#5E81AC";
    base0B = "#BF616A";
    base0C = "#D08770";
    base0D = "#EBCB8B";
    base0E = "#A3BE8C";
    base0F = "#B48EAD";
  };

  workspaces = [ 1 2 3 4 5 6 7 8 9 ];

  workspaceKeybinds1 = map (ws: {
    "${modifier}+${ws}" = "workspace number ${ws}";
    "${modifier}+Shift+${ws}" = "move container to workspace number ${ws}";
  }) workspaces;

  workspaceKeybinds = (builtins.trace workspaceKeybinds1 workspaceKeybinds1);
in {
  home.packages = with pkgs; [ grim slurp wl-clipboard ];

  wayland.windowManager.sway = {
    enable = true;

    config = {
      inherit modifier;

      bars = [ ]; # TODO

      colors = {
        background = colors.base07;
        focused = with colors; {
          border = base05;
          background = base0D;
          text = base00;
          indicator = base0D;
          childBorder = base0C;
        };
        focusedInactive = with colors; {
          border = base01;
          background = base01;
          text = base05;
          indicator = base03;
          childBorder = base01;
        };
        placeholder = with colors; {
          border = base00;
          background = base00;
          text = base05;
          indicator = base00;
          childBorder = base00;
        };
        unfocused = with colors; {
          border = base01;
          background = base00;
          text = base05;
          indicator = base01;
          childBorder = base01;
        };
        urgent = with colors; {
          border = base08;
          background = base08;
          text = base00;
          indicator = base08;
          childBorder = base08;
        };
      };

      floating = {
        border = 3;
        criteria = [{ title = "Steam - Update News"; }];
      };

      focus = {
        followMouse = true;
        mouseWarping = false;
      };

      fonts = [ "monospace 8" ];
      gaps = {
        smartBorders = true;
        smartGaps = true;
      };

      input."*" = {
        xkb_layout = "eu";
        xkb_options = "caps:swapescape";
      };

      keybindings = {
        "${modifier}+Return" = "exec alacritty";
        "${modifier}+p" = "exec wofi run";
        "${modifier}+Print" = ''grim -g "$(slurp)" - | wl-copy'';

        "${modifier}+q" = "kill";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+Shift+space" = "floating toggle";

        "${modifier}+Shift+r" = "reload";
        "${modifier}+Shift+e" =
          "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";

        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";

        "${modifier}+r" = "mode resize";

        "${modifier}+Shift+s" = "move scratchpad";
        "${modifier}+s" = "scratchpad show";

      } // workspaceKeybinds;

      output."*".bg = "${../../../../background-image.png} fill";
    };

    wrapperFeatures = { gtk = true; };
  };
}