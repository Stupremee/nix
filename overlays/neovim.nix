final: prev: {
  neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (_: {
    inherit (prev.sources.neovim) pname version src;
  });

  neovim = prev.neovim.override {
    vimAlias = true;
    viAlias = true;

    configure.packages.basePackage = with prev.vimPlugins; {
      start = [
        vim-eunuch
        nvim-bufdel
      ];
    };
  };
}
