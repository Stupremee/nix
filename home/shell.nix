{ config, ... }: {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;


    history.path = "${config.xdg.dataHome}/zsh/zshHistory";
  };

  programs.atuin = {
    enable = false;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    nix-direnv.enable = true;
  };
}
