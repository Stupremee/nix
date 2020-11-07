{ buildVimPluginFrom2Nix, fetchFromGitHub }:

{
  a-vim = buildVimPluginFrom2Nix {
    pname = "a-vim";
    version = "2010-11-06";
    src = fetchFromGitHub {
      owner = "arcticicestudio";
      repo = "nord-im";
    };
    meta.homepage = "https://github.com/arcticicestudio/nord-vim";
  };
}
