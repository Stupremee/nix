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

  snap = buildVimPlugin {
    name = "snap";
    src = fetchFromGitHub {
      owner = "camspiers";
      repo = "snap";
      rev = "2e65f787e45c525e330c6b8d091164b5ed1fc4f8";
      sha256 = "sha256-xwePCzG9s+HOF+QyIKaLfui7Uz780EzTZ1F8U6c3AdE=";
    };
  };

  github-nvim-theme = buildVimPlugin {
    name = "github-nvim-theme";
    src = fetchFromGitHub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "ca6a37e229b899789418deb3b8435e30661e0ecf";
      sha256 = "sha256-8JuvYEWlIQ0Cez8ZUjS6sTAzbhJKWjqWguGMksetq9o=";
    };

    # Dirty hack to stop Nix from executing the Makefile
    prePatch = ''
      rm Makefile
    '';
  };
}
