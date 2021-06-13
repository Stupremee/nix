{ config, options, lib, pkgs, ... }:

with lib;
let cfg = config.programs.themes;
in
{
  options.programs.themes = {
    theme = mkOption {
      type = types.str;
    };
  };

  config = { };
}
