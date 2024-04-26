{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
    neodev-nvim
  ];

  extraConfigLua = ''
    require("neodev").setup({
      library = { types = true},
    })
  '';
}
