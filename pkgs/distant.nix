{ lib, rustPlatform, fetchFromGitHub, openssl }:
rustPlatform.buildRustPackage rec {
  pname = "distant";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "chipsenkbeil";
    repo = "distant";
    rev = "v${version}";
    sha256 = "sha256-ekCW9zHmVF/VJQQO0rBqo5nQ7aVBADgH+xV5/XTyeko=";
  };

  nativeBuildInputs = [ openssl ];

  cargoBuildFlags = [ "--no-default-features" ];

  doCheck = false;

  cargoSha256 = "sha256-Bpri1phMH+vGZgBrTo2DBYN4kVB5D7cjbGNc8sKAt3Q=";
}
