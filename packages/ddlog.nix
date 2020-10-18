{ stdenv, autoPatchelfHook, gnutar, fetchurl }:

stdenv.mkDerivation rec {
  name = "ddlog";
  version = "0.28.0";

  src = fetchurl {
    url = "https://github.com/vmware/differential-datalog/releases/download/v0.28.0/ddlog-v0.28.0-20201006171257-linux.tar.gz";
    sha256 = "68be277c87266c03aee00128fbe3ac31efa4ade3e46f483da3faa144b6c387ac";
  };

  nativeBuildInputs = [ gnutar ];

  dontBuild = true;
  unpackPhase = ''
    tar xf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -a ddlog/bin/ddlog $out/bin/ddlog
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/vmware/differential-datalog;
    description = "An incremental programming language ";
    platforms = platforms.linux;
    maintainers = with maintainers; [ VMWare ];
  };
}

