{ pkgs, ... }: {
  programs.helix = {
    enable = true;

    extraPackages = with pkgs; [
      rust-analyzer
      rnix-lsp
    ];

    config.theme = "nord";
    config.lsp.display-messages = true;

    language.nix = {
      auto-format = true;
    };
  };
}
