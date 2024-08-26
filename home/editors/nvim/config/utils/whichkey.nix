{
  plugins.which-key = {
    enable = true;

    settings = {
      ignore_missing = false;

      icons = {
        breadcrumb = "»";
        group = "+";
        separator = ""; # ➜
      };

      win = {
        border = "none";
        wo.winblend = 0;
      };
    };

    # registrations = {
    #   "<leader>t" = " Terminal";
    # };
  };
}
