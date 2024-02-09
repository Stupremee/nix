# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  authelia = {
    pname = "authelia";
    version = "v4.37.5";
    src = fetchFromGitHub {
      owner = "authelia";
      repo = "authelia";
      rev = "v4.37.5";
      fetchSubmodules = false;
      sha256 = "sha256-xsdBnyPHFIimhp2rcudWqvVR36WN4vBXbxRmvgqMcDw=";
    };
  };
  authelia-web = {
    pname = "authelia-web";
    version = "v4.37.5";
    src = fetchTarball {
      url = "https://github.com/authelia/authelia/releases/download/v4.37.5/authelia-v4.37.5-public_html.tar.gz";
      sha256 = "1sq90s0f5l7l0675jyaa6xm6kx0likdz0cc13kz86726sdq7vhhv";
    };
  };
  dymoprint = {
    pname = "dymoprint";
    version = "2.4.0";
    src = fetchurl {
      url = "https://pypi.org/packages/source/d/dymoprint/dymoprint-2.4.0.tar.gz";
      sha256 = "sha256-c/0BXfG0g0tg+256nyP5d4VRI4GMippw//h54PVndIU=";
    };
  };
  kanidm = {
    pname = "kanidm";
    version = "v1.1.0-rc.16";
    src = fetchFromGitHub {
      owner = "kanidm";
      repo = "kanidm";
      rev = "v1.1.0-rc.16";
      fetchSubmodules = false;
      sha256 = "sha256-NH9V5KKI9LAtJ2/WuWtUJUzkjVMfO7Q5NQkK7Ys2olU=";
    };
  };
  tailscale = {
    pname = "tailscale";
    version = "v1.58.2";
    src = fetchFromGitHub {
      owner = "tailscale";
      repo = "tailscale";
      rev = "v1.58.2";
      fetchSubmodules = false;
      sha256 = "sha256-FiFFfUtse0CKR4XJ82HEjpZNxCaa4FnwSJfEzJ5kZgk=";
    };
  };
  tproxy = {
    pname = "tproxy";
    version = "v0.8.0";
    src = fetchFromGitHub {
      owner = "kevwan";
      repo = "tproxy";
      rev = "v0.8.0";
      fetchSubmodules = false;
      sha256 = "sha256-d4ZijF3clu00WZQGlurTkGkedurjt9fqfShdjbZWCSI=";
    };
  };
}
