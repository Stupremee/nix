# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  base64-nvim = {
    pname = "base64-nvim";
    version = "67fb5f12db252b3e2bd190250d3edbed7aa8d3aa";
    src = fetchFromGitHub ({
      owner = "moevis";
      repo = "base64.nvim";
      rev = "67fb5f12db252b3e2bd190250d3edbed7aa8d3aa";
      fetchSubmodules = false;
      sha256 = "sha256-eByAH1iy7Px/AhtA6FzMPgP56TgaR0p+UumXrHmlbuU=";
    });
  };
  dressing-nvim = {
    pname = "dressing-nvim";
    version = "5f44f829481640be0f96759c965ae22a3bcaf7ce";
    src = fetchFromGitHub ({
      owner = "stevearc";
      repo = "dressing.nvim";
      rev = "5f44f829481640be0f96759c965ae22a3bcaf7ce";
      fetchSubmodules = false;
      sha256 = "sha256-89HwP+zxMN5CPPN3dd3yMfCB07mtBhv6lcWuEWnedfw=";
    });
  };
  kanidm = {
    pname = "kanidm";
    version = "v1.1.0-alpha.11";
    src = fetchFromGitHub ({
      owner = "kanidm";
      repo = "kanidm";
      rev = "v1.1.0-alpha.11";
      fetchSubmodules = false;
      sha256 = "sha256-TVGLL1Ir/Nld0kdhWmcYYmChrW42ctJPY/U7wtuEwCo=";
    });
  };
  lsp-zero-nvim = {
    pname = "lsp-zero-nvim";
    version = "07e43a593241bce72c0854398b16f51e0b46486e";
    src = fetchFromGitHub ({
      owner = "VonHeikemen";
      repo = "lsp-zero.nvim";
      rev = "07e43a593241bce72c0854398b16f51e0b46486e";
      fetchSubmodules = false;
      sha256 = "sha256-M/vRqwEbhnTiEtJRPKvB2D49Z+FtbUbcVII3FNdoYsw=";
    });
  };
}
