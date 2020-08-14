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
      ];

      env.PATH = [ "$HOME/.emacs.d/bin" ];

      home.home.file.".doom.d".source = <config/doom>;
    };

    fonts.fonts = [
      pkgs.emacs-all-the-icons-fonts
    ];
  };
}
