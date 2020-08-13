{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.dev.rust = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.rust.enable {
    my = {
      packages = with pkgs; [
        rustup
      ];

      env.RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
      env.CARGO_HOME = "$XDG_DATA_HOME/cargo";
      env.CARGO_TARGET = "$XDG_CACHE_DIR/cargo_target";
      env.PATH = [ "$CARGO_HOME/bin" ];
    };
  };
}

