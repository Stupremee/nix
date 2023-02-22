{
  source,
  vimUtils,
}:
vimUtils.buildVimPluginFrom2Nix {inherit (source) pname version src;}
