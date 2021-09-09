{ stdenv
, fetchFromGitHub
, git
, bat
, pandoc
, ripgrep
, ripgrep-all
, exa
, xpdf
, nmap
}:
stdenv.mkDerivation rec {
  pname = "nb";
  version = "6.4.0";

  src = fetchFromGitHub {
    owner = "xwmx";
    repo = "nb";
    rev = "${version}";
    sha256 = "sha256-Rhg4C009siIp0NbJ9SIkaj96XLMX9JxZsTCwLCXkOG8=";
  };

  buildInputs = [
    git
    bat
    pandoc
    ripgrep
    ripgrep-all
    exa
    xpdf
    nmap
  ];

  prePatch = ''
    rm Makefile
  '';

  installPhase = ''
    install -D ./etc/nb-completion.zsh $out/share/zsh/site-functions/_nb

    mkdir -p $out/bin
    install -D nb $out/bin/nb
    install -D bin/{bookmark,notes} $out/bin/
  '';
}
