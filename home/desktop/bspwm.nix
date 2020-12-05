{ pkgs, ... }:
let
  inherit (builtins) concatStringsSep concatLists attrValues;

  desktops = {
    primary = [ "code" "web" "term" "media" "V" ];
    secondary = [ "web2" "media2" "IIX" "IX" "X" ];
  };

  desktopStrings = concatStringsSep "," (concatLists (attrValues desktops));
in {
  home.packages = with pkgs; [ playerctl pulsemixer maim ];

  xsession = {
    enable = true;
    windowManager.bspwm = {
      enable = true;

      monitors = {
        HDMI-0 = desktops.primary;
        DP-3 = desktops.secondary;
      };

      settings = {
        focus_follows_pointer = true;
        borderless_monocle = true;
        gapless_monocle = true;

        border_width = 3;
        window_gap = 15;
        bottom_padding = 8;

        # Nord theme
        normal_border_color = "#3b4252";
        active_border_color = "#3b4252";
        focused_border_color = "#5e81ac";
        presel_feedback_color = "#5e81ac";
      };

      # home-manager doesn't allow it to provide settings with a `-m` argument
      extraConfig = ''
        bspc config -m primary top_padding 40
      '';

      startupPrograms = [
        "$HOME/.fehbg"
      ];

      rules = {
        "Pinentry" = {
          state = "floating";
          center = true;
        };
      };
    };
  };

  services.sxhkd = {
    enable = true;

    keybindings = {
      "super + Return" = "alacritty";
      "super + p" = "rofi -show combi";
      "super + shift + w" = "$BROWSER";
      "super + Print" = "${pkgs.maim}/bin/maim -s | ${pkgs.xclip}/bin/xclip -sel c -t image/png";

      "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86Audio{Raise,Lower}Volume" = "pulsemixer --change-volume {+,-}5";
      "XF86Audio{Next,Prev}" = "playerctl {next,previous}";
      "XF86Audio{Play,Stop}" = "playerctl {play-pause,stop}";

      # Close or kill application
      "super + {_, shift + }q" = "bspc node -{c,k}";
      # Make the app fullscreen
      "super + {_, shift + }f" = "bspc {desktop -l next,node -t ~fullscreen}";
      # Rotate current setup by 90 degrees
      "super + y" = "bspc node @focused:/ -R 90";
      # Switch current window with the biggest window
      "super + @space" =
        "bspc node -s biggest.local || bspc node -s next.local";
      # Make window floating
      "super + shift + space" = "bspc node focused -t ~floating";
      # Quit / Restart bspwm
      "super + shift + {e,r}" = "bspc {quit,wm -r}";

      # Switch the focus using hjkl
      "super + {_,shift +}{h,j,k,l}" =
        "bspc node -{f,s} {west,south,north,east}";
      # Focus workspace or send window to workspace
      "super + {_,shift + }{1-9,0}" =
        "bspc {desktop -f,node -d} {${desktopStrings}}";
      # Preselect ratio of the new windows size
      "super + ctrl + {1-9}" = "bspc node -o .{1-9}";
      # Cancel preselection
      "super + ctrl + space" = "bspc node -p cancel";
      # Resize windows in a smart way
      "super + alt + {h,j,k,l}" = ''
        n=10; \
        { d1=left;   d2=right;  dx=-$n; dy=0;   \
        , d1=bottom; d2=top;    dx=0;   dy=$n;  \
        , d1=top;    d2=bottom; dx=0;   dy=-$n; \
        , d1=right;  d2=left;   dx=$n;  dy=0;   \
        } \
        bspc node --resize $d1 $dx $dy || bspc node --resize $d2 $dx $dy
      '';
    };
  };

  programs.rofi.enable = true;

  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./rofi.rasi;
}
