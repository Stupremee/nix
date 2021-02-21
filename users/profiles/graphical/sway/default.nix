{ pkgs, lib, ... }:
let
  inherit (builtins) readFile map toString;
  inherit (lib.lists) fold;

  modifier = "Mod4";

  style = readFile ./style.css;

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

  workspaces = map toString [ 1 2 3 4 5 6 7 8 9 ];

  workspaceKeybinds =
    let
      keybinds = map
        (ws: {
          "${modifier}+${ws}" = "workspace number ${ws}";
          "${modifier}+Shift+${ws}" = "move container to workspace number ${ws}";
        })
        workspaces;
    in
    fold (a: b: a // b) { } keybinds;

  startSway = pkgs.writeScriptBin "startsway" ''
    #!${pkgs.zsh}/bin/zsh
    [[ "$TTY" == /dev/tty* ]] || return 0

    systemctl --user import-environment
    if [[ -z $DISPLAY && "$TTY" == "/dev/tty1" ]]; then
      exec systemd-cat -t sway sway
    fi
  '';

  profileExtra = ''
    exec ${startSway}/bin/startsway
  '';
in
{
  home.packages = with pkgs; [ grim slurp wl-clipboard wofi swaylock swayidle ];

  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;

    config = {
      inherit modifier;

      bars = [{
        command = "${pkgs.waybar}/bin/waybar";
      }];

      colors = {
        background = colors.base07;
        focused = with colors; {
          border = base05;
          background = base0D;
          text = base00;
          indicator = base0D;
          childBorder = base08;
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
        smartBorders = "on";
        smartGaps = true;

        inner = 10;
        outer = 10;
      };

      input."*" = {
        xkb_layout = "eu";
        xkb_options = "caps:swapescape";
      };

      keybindings = {
        "${modifier}+Return" = "exec alacritty";
        "${modifier}+p" = "exec wofi --show run";
        "${modifier}+Print" = ''exec grim -g "$(slurp)" - | wl-copy -t image/png'';

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

      output."eDP-1".scale = "1.5";
    };

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';

    wrapperFeatures = { gtk = true; };
  };

  programs.waybar = {
    enable = true;

    inherit style;

    settings = [{
      layer = "top";
      position = "top";
      height = 30;
      output = [ "eDP-1" ];

      modules-left = [ "sway/workspaces" ];
      modules-center = [ "wlr/taskbar" ];
      modules-right = [ "pulseaudio" "disk" "memory" "cpu" "network" "battery" "clock" ];

      modules = {
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        "clock" = {
          format = "{:%I:%M %p}";
          tooltip = false;
        };

        "battery" = {
          bat = "BAT0";
          states = {
            good = 95;
            warning = 30;
            critical = 10;
          };

          format = "{capacity}%  {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ﮣ";
          format-icons = [ "" "" "" "" "" ];
        };

        "disk" = {
          interval = 30;
          format = "{free}";
          path = "/";
        };

        "network" = {
          format-wifi = "  connected";
          format-ethernet = "{ifname}: {ipaddr} ";
          format-linked = "{ifname} (no IP) ";
          format-disconnected = " Disconnected ";
          format-alt = "{ifname}: {ipaddr}";
          interval = 60;
        };

        "memory" = {
          format = "{} ";
        };

        "cpu" = {
          format = "{} ";
        };

        "pulseaudio" = {
          scroll-step = 1;
          format = "{icon}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = "ﱝ {icon} {format_source}";
          format-muted = "ﱝ {format_source}";

          format-source = "{volume}% ";
          format-source-muted = "";

          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "  -" "  --" "  ---" "  ----" "  -----" "  ------" "  -------" "  --------" "  ---------" "  ----------" ];
          };

          # TODO: Open mixer in a floating terminal
          # on-click = "pulsemixer";
        };

        "wlr/taskbar" = {
          all-outputs = false;
          format = "{icon}";
          max-length = 10;
          icon-theme = "Papirus";
          icon-size = 15;
          on-click = "activate";
          on-click-middle = "close";
        };
      };
    }];
  };

  programs.zsh.profileExtra = profileExtra;
  programs.bash.profileExtra = profileExtra;
}
