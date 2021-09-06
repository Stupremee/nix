{ lib, rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "distant";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "chipsenkbeil";
    repo = "distant";
    rev = "v${version}";
    sha256 = "sha256-nI3/ShUOFB/6SbMN2l8igot6eaaTJjmNfpdfMEBfgSQ=";
  };

  doCheck = false;

  cargoSha256 = "sha256-sKOOBYcfcAYp10u1HLMjXAtiF7MUdHpRYdcsSU1IedA=";
}
