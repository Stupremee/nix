{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, installShellFiles
, libiconv
, dbus
}:

rustPlatform.buildRustPackage rec {
  pname = "starship";
  version = "0.49.0";

  src = fetchFromGitHub {
    owner = "starship";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/JVuPXgNze9N9TW/tqazcaQXr9EpSaYMQePwDGmXkFU=";
  };

  nativeBuildInputs = [ installShellFiles pkg-config ];

  buildInputs = [ openssl dbus ];

  postInstall = ''
    for shell in bash fish zsh; do
      STARSHIP_CACHE=$TMPDIR $out/bin/starship completions $shell > starship.$shell
      installShellCompletion starship.$shell
    done
  '';

  cargoSha256 = "sha256-wkr058SoHjqWee0jtWlWYf9+rxHyzhuc/eqz98e2J3A=";
  cargoBuildFlags = [ "--features=notify-rust" ];

  preCheck = ''
    HOME=$TMPDIR
  '';

  meta = with lib; {
    description =
      "A minimal, blazing fast, and extremely customizable prompt for any shell";
    homepage = "https://starship.rs";
    license = licenses.isc;
  };
}
