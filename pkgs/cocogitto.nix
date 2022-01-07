{ lib, rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "cocogitto";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "oknozor";
    repo = "cocogitto";
    rev = "${version}";
    sha256 = "sha256-uSKzHo1lEBiXsi1rOKvfD2zVlkAUVZ5k0y8iiTXYE2A=";
  };

  postInstall = ''
    mkdir -p $out/share/zsh/site-functions

    $out/bin/cog generate-completions zsh > $out/share/zsh/site-functions/_cog
    $out/bin/coco --completion zsh > $out/share/zsh/site-functions/_coco
  '';

  doCheck = false;
  cargoSha256 = "sha256-gss3+XXyM//zER3gnN9qemIWaVDfs/f4gljmukMxoq0=";
}
