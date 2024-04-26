{
  plugins.nvim-tree = {
    enable = true;

    updateFocusedFile = {
      enable = true;
      updateRoot = false;
    };

    renderer = {
      rootFolderLabel = "";

      icons.glyphs = {
        default = "";
        symlink = "";

        folder = {
          arrowOpen = "";
          arrowClosed = "";
          default = "";
          open = "";
          empty = "";
          emptyOpen = "";
          symlink = "";
          symlinkOpen = "";
        };

        git = {
          unstaged = "";
          staged = "S";
          unmerged = "";
          renamed = "➜";
          untracked = "U";
          deleted = "";
          ignored = "◌";
        };
      };
    };

    diagnostics = {
      enable = true;
      showOnDirs = true;
      icons = {
        hint = "󰌵";
        info = "";
        warning = "";
        error = "";
      };
    };

    view = {
      side = "left";
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>e";
      action = ":NvimTreeToggle<cr>";
      options = {
        silent = true;
        desc = "Explorer Nvim-Tree (root dir)";
      };
    }
  ];
}
