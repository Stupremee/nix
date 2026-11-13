{
  stdenvNoCC,
  esbuild,
  typescript,
}:
# Lovelace cards for the Technik dashboard: heizung-card and verdichter-card.
# No npm dependencies, so tsc checks and esbuild bundles straight from src.
stdenvNoCC.mkDerivation {
  pname = "technik-cards";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [
    esbuild
    typescript
  ];

  buildPhase = ''
    runHook preBuild
    tsc -p .
    esbuild src/index.ts --bundle --format=esm --target=es2022 --minify --outfile=technik-cards.js
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm444 technik-cards.js $out/technik-cards.js
    runHook postInstall
  '';
}
