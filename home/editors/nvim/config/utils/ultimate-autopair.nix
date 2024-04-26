{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
    ultimate-autopair-nvim
  ];

  extraConfigLua = ''
    require('ultimate-autopair').setup()
  '';
}
