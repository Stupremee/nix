{
  pkgs,
  unstable-pkgs,
  theme,
  packages,
  theme,
  ...
}: {
  programs.helix = {
    enable = true;
    package = unstable-pkgs.helix;

    extraPackages = with unstable-pkgs; [
      packages."@volar/vue-language-server"
      rust-analyzer
    ];

    settings = {
      theme = "catppuccin_${theme.name}";

      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        indent-guides.render = true;
      };
    };

    languages = {
      language-server.typescript-language-server = with pkgs.nodePackages; {
        command = "${typescript-language-server}/bin/typescript-language-server";
        args = ["--stdio" "--tsserver-path=${typescript}/lib/node_modules/typescript/lib"];
      };

      language-server.vuels = with pkgs.nodePackages; {
        config = {
          typescript.tsdk = "${typescript}/lib/node_modules/typescript/lib";
        };
      };
    };

    themes.catppuccin = {
        "attribute" = "yellow";
    };
}
