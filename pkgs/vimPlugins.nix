# Collection of vim plugins that are not packaged in nixpkgs.
{ vimUtils, fetchFromGitHub, ... }:
with vimUtils;
{
  lightspeed-nvim = buildVimPlugin {
    name = "lightspeed-nvim";
    src = fetchFromGitHub {
      owner = "ggandor";
      repo = "lightspeed.nvim";
      rev = "5d132ec1341dcecba22710f3749cf84a7a8422f2";
      sha256 = "sha256-KIaKdThTkj0vyUSw3lmYETbHHuSCDH7i1ZnvvSsXsEg=";
    };
  };
}
