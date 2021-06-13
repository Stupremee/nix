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
    ];
    blur = true;

    shadow = true;
  };
}
