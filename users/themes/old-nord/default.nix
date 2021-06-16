{ pkgs, ... }:
let
  loadYaml = path: (yamlToJson path);

  yamlToJson = path:
    pkgs.runCommand "yaml2json" { nativeBuildInputs = [ pkgs.yq-go ]; }
      "${pkgs.yq-go}/bin/yq e -j ${path} > $out";

  colors = builtins.fromJSON (builtins.readFile (loadYaml ./alacritty.yaml));
in
{
  alacritty = {
    inherit (colors) colors;
  };

  bspwm = {
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
  };

  picom = {
    activeOpacity = "1.0";
    inactiveOpacity = "1.0";
    blur = true;
  };
}