{ pkgs, ... }:
let
  loadYaml = path: (yamlToJson path);

  yamlToJson = path:
    pkgs.runCommand "yaml2json" { nativeBuildInputs = [ pkgs.yq-go ]; }
      "${pkgs.yq-go}/bin/yq e -j ${path} > $out";

  colors = builtins.fromJSON (builtins.readFile (loadYaml ./alacritty.yaml));
in
{
  wallpaper = ./wallpaper.jpg;

  alacritty = {
    inherit (colors) colors;
  };

  bspwm = {
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
  };

  picom = {
    # activeOpacity = "0.8";
    # inactiveOpacity = "0.8";
    opacityRule = [
      "85:class_i ?= 'alacritty'"
      "85:class_i ?= 'dunst'"
    ];
    blur = true;

    shadow = true;
  };

  dunst.iconTheme = {
    name = "Papirus";
    package = pkgs.papirus-icon-theme;
    size = "48x48";
  };

  dunst.settings = {
    global = {
      monitor = 0;
      geometry = "320x6-24+48";
      indicate_hidden = "yes";
      shrink = "no";

      separator_height = "3";
      separator_color = "#E5E9F0";

      padding = "16";
      horizontal_padding = "16";
      frame_width = "0";
      sort = "no";
      idle_threshold = "0";
      font = "Noto Sans 10";
      line_height = "0";

      markup = "full";
      format = "<b>%a</b>\n%s";

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

  tmux = {
    plugins = [ pkgs.tmuxPlugins.nord ];
  };
}
