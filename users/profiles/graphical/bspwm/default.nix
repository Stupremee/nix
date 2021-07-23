{ pkgs, lib, config, ... }:
let
  inherit (builtins) concatStringsSep concatLists attrValues;

  desktops = {
    primary = [ "I" "II" "III" "IV" "V" "VI" "VII" ];
    secondary = [ "IIX" "IX" "X" ];
  };

  desktopStrings = concatStringsSep "," (concatLists (attrValues desktops));

  wallpaper = ../../../../wallpapers/nord-mountains.jpg;
in
{
  home.packages = with pkgs; [ playerctl rofi feh dunst ];

  xsession.enable = true;
  xsession.windowManager.bspwm = {
    enable = true;

    monitors = {
      HDMI-0 = desktops.primary;
      DP-1 = desktops.secondary;
    };

    settings = {
      focus_follows_pointer = true;
      borderless_monocle = true;
      gapless_monocle = true;

      border_width = 0;
      window_gap = 10;
      top_padding = 8;
      bottom_padding = 8;

      # Nord theme
      normal_border_color = "#3b4252";
      active_border_color = "#3b4252";
      focused_border_color = "#5e81ac";
      presel_feedback_color = "#5e81ac";
    };

    # home-manager doesn't allow it to provide settings with a `-m` argument
    # extraConfig = ''
    # bspc config -m primary top_padding 40
    # '';

    # Set wallpaper using `feh`
    startupPrograms = [
      "${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${wallpaper}"
    ];

    rules = {
      "Pinentry" = {
        state = "floating";
        center = true;
      };
    };
  };

  services.sxhkd = {
    enable = true;

    keybindings = {
      "super + Return" = "${config.home.sessionVariables.TERMINAL}";
      "super + p" = "rofi -show combi";
      "super + shift + w" = "$BROWSER";
      "super + shift + s" = "${pkgs.maim}/bin/maim -s | ${pkgs.xclip}/bin/xclip -sel c -t image/png";

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
      "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} {${desktopStrings}}";
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

  services.picom = {
    enable = true;

    # activeOpacity = "0.8";
    # inactiveOpacity = "0.8";
    opacityRule = [
      "85:class_i ?= 'org.wezfurlong.wezterm'"
      "85:class_i ?= 'alacritty'"
      "90:class_i ?= 'discord'"
    ];

    blur = false;
    shadow = false;
  };

  services.dunst = {
    enable = true;

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
      size = "48x48";
    };

    settings = {
      global = {
        monitor = 0;
        geometry = "320x6-24+48";
        indicate_hidden = "yes";
        shrink = "no";

        separator_height = "1";
        separator_color = "#E5E9F0";

        padding = "16";
        horizontal_padding = "16";
        frame_width = "0";
        sort = "no";
        idle_threshold = "0";
        font = "Noto Sans Nerd Font 10";
        line_height = "0";

        markup = "full";
        format = "<b>%a - %s</b>\\n%b";

        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = "120";
        word_wrap = "yes";
        ignore_newline = "no";
        stack_duplicates = "false";
        show_indicators = "yes";

        sticky_history = "yes";
        history_length = "100";

        title = "Dunst";
        class = "Dunst";

        startup_notification = "false";
        corner_radius = "0";
        ignore_dbusclose = "false";

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";

        icon_position = "left";
        min_icon_size = "0";
        max_icon_size = "20";
      };

      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+period";
      };

      urgency_low = {
        background = "#3B4252";
        foreground = "#4C566A";
        timeout = 10;
      };

      urgency_normal = {
        background = "#434C5E";
        foreground = "#E5E9F0";
        timeout = 10;
      };

      urgency_critical = {
        background = "#BF616A";
        foreground = "#ECEFF4";
        timeout = 0;
      };
    };
  };
}
