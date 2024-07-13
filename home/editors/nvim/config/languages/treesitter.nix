{
  plugins.treesitter = {
    enable = true;
    folding = true;
    nixvimInjections = true;

    settings.indent.enable = true;
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
