{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.modules.zellij;
in
{
  options.modules.zellij = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    theme = mkOption {
      type = types.path;
    };
  };

  config =
    let
      theme = import cfg.theme { inherit pkgs; };
    in
    mkIf cfg.enable {
      home.packages = [ pkgs.zellij ];
      xdg.configFile."zellij/config.yaml".text = ''
        ${theme.zellij.config}

        keybinds:
          unbind: [ Ctrl: 'o']
      '';
    };
}
