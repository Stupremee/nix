{
  withNodeJs = true;

  plugins.copilot-lua = {
    enable = true;
    panel = {
      enabled = false;
      autoRefresh = true;
      keymap = {
        jumpPrev = "[[";
        jumpNext = "]]";
        accept = "<CR>";
        refresh = "gr";
        open = "<M-CR>";
      };
      layout = {
        position = "bottom"; # | top | left | right
        ratio = 0.4;
      };
    };
    suggestion = {
      enabled = false;
      autoTrigger = true;
      debounce = 75;
      keymap = {
        accept = "<C-f>";
        acceptWord = false;
        acceptLine = false;
        next = "<C-Right>";
        prev = "<C-Left>";
        dismiss = "<C-b>";
      };
    };
    filetypes = {
      yaml = false;
      help = false;
      gitcommit = false;
      gitrebase = false;
      hgcommit = false;
      svn = false;
      cvs = false;
      "." = false;
    };
    copilotNodeCommand = "node"; # Node.js version must be > 18.x
    serverOptsOverrides = {};
  };
}
