{...}: {
  plugins.trouble = {
    enable = true;
    settings = {
      auto_close = true;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>x";
      action = "+diagnostics/quickfix";
    }
    {
      mode = "n";
      key = "<leader>xx";
      action = ''function() require("trouble").toggle() end'';
      options = {
        silent = true;
        desc = "Trouble Window";
      };
    }
    {
      mode = "n";
      key = "<leader>xw";
      action = ''function() require("trouble").toggle("workspace_diagnostics") end'';
      options = {
        silent = true;
        desc = "Workspace Diagnostics (Trouble)";
      };
    }
    {
      mode = "n";
      key = "<leader>xd";
      action = ''function() require("trouble").toggle("document_diagnostics") end'';
      options = {
        silent = true;
        desc = "Document Diagnostics (Trouble)";
      };
    }
    {
      mode = "n";
      key = "<leader>xq";
      action = ''function() require("trouble").toggle("quickfix") end'';
      options = {
        silent = true;
        desc = "Quickfix (Trouble)";
      };
    }
    {
      mode = "n";
      key = "<leader>xl";
      action = ''function() require("trouble").toggle("loclist") end'';
      options = {
        silent = true;
        desc = "Loc List (Trouble)";
      };
    }
  ];
}
