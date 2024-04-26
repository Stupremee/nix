{helpers, ...}: {
  plugins.lualine = {
    enable = true;
    alwaysDivideMiddle = true;
    globalstatus = true;
    ignoreFocus = ["nvimtree"];
    extensions = ["fzf"];
    theme = "auto";

    componentSeparators = {
      left = "|";
      right = "|";
    };
    sectionSeparators = {
      left = "█"; # 
      right = "█"; # 
    };
    sections = {
      lualine_a = ["mode"];
      lualine_b = [
        {
          name = "branch";
          icon = "";
        }
        "diff"
        "diagnostics"
      ];
      lualine_c = [
        "filename"
        {
          extraConfig.cond = helpers.mkRaw ''require("noice").api.statusline.mode.has'';
          fmt = ''require("noice").api.status.mode.get'';
        }
      ];
      lualine_x = ["filetype"];
      lualine_y = ["progress"];
      lualine_z = ["location"];
    };
  };
}
