{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "1.21.1";
  releases = {
    x86_64-linux = {
      platform = "linux-x64";
      hash = "sha256-OSC0aW4ZIih0AhE9rXOjG33qlJc8y7qPJigCCiDSJDo=";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      hash = "sha256-Ad/QSqgzxEXh8R1yBvgLTvX3eTFhq80cxbduO5NGIlw=";
    };
    aarch64-darwin = {
      platform = "macos-arm64";
      hash = "sha256-n7N3nGWNd+DmgmX2oouDUPygrdnDxxnnlw6pouzEsbc=";
    };
    x86_64-darwin = {
      platform = "macos-x64";
      hash = "sha256-WxYb5NbWUywg8oELpDO5n2DxDFtzJWdZYcpYa9CMPGc=";
    };
  };
  release = releases.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "varlock";
  inherit version;

  src = fetchurl {
    url = "https://github.com/dmno-dev/varlock/releases/download/varlock%40${version}/varlock-${release.platform}.tar.gz";
    inherit (release) hash;
  };

  sourceRoot = ".";
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 varlock "$out/bin/varlock"
    install -Dm755 varlock-local-encrypt "$out/bin/varlock-local-encrypt"
    runHook postInstall
  '';

  meta = {
    description = "Load and validate environment variables without exposing secrets";
    homepage = "https://varlock.dev";
    license = lib.licenses.mit;
    mainProgram = "varlock";
    platforms = builtins.attrNames releases;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
