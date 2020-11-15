{ ... }: {
  imports = [ ./neovim ];

  # Language servers
  home.packages = with pkgs; [ terraform-ls rust-analyzer ];

  home.sessionVariables = { EDITOR = "nvim"; };
}
