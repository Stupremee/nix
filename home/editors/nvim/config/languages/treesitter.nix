{
  plugins.treesitter = {
    enable = true;
    indent = true;
    folding = true;
    nixvimInjections = true;
  };

  plugins.treesitter-context = {
    enable = false;
  };

  plugins.ts-autotag = {
    enable = true;
  };

  plugins.ts-context-commentstring = {
    enable = true;
    disableAutoInitialization = false;
  };
}
