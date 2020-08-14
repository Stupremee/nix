{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.editors.emacs = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.editors.emacs.enable {
    my = {
      packages = with pkgs; [
        emacs
        git
        (ripgrep.override {withPCRE2 = true;})
        gnutls

        fd
        zstd

        aspell
        aspellDicts.en
        aspellDicts.en-computers
        aspellDicts.en-science
        languagetool
        editorconfig-core-c
        rust-analyzer
      ];

      env.PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];
    };

    fonts.fonts = [
      pkgs.emacs-all-the-icons-fonts
    ];
  };
}
