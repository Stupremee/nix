{theme, ...}: {
  colorschemes = {
    catppuccin = {
      enable = true;

      settings = {
        background = {
          light = "frappe";
          dark = "frappe";
        };
        flavour = theme.name; # "latte", "mocha", "frappe", "macchiato" or raw lua code

        disableBold = false;
        disableItalic = false;
        disableUnderline = false;
        transparentBackground = true;

        integrations = {
          cmp = true;
          noice = true;
          notify = true;
          nvimtree = true;
          harpoon = true;
          gitsigns = true;
          which_key = true;
          illuminate = {
            enabled = true;
          };
          treesitter = true;
          treesitter_context = true;
          telescope.enabled = true;
          indent_blankline.enabled = true;
          mini.enabled = true;
          native_lsp = {
            enabled = true;
            inlay_hints = {
              background = true;
            };
            underlines = {
              errors = ["underline"];
              hints = ["underline"];
              information = ["underline"];
              warnings = ["underline"];
            };
          };
        };
      };
    };
  };
}
