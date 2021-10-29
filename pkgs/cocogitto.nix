{ lib, rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "cocogitto";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "oknozor";
    repo = "cocogitto";
    rev = "81ad8446ac018caff94ef4369c8049b30c012b6e";
    sha256 = "sha256-CVNG/94bLTCVHJF7qjdxrrobZ6fQSyWk+yLKDROp3TI=";
  };

  doCheck = false;
  cargoSha256 = "sha256-L423cgvQd8EMrJCOLG/fnyZQ1+8/n0oXq8so5CT7YsI=";
}
