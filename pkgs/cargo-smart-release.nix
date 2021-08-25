{ stdenv, lib, fetchFromGitHub, rustPlatform, runCommand, cmake, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "cargo-smart-release";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "Byron";
    repo = "gitoxide";
    rev = "cargo-smart-release-v${version}";
    sha256 = "sha256-OrCWYowT/v1/6XmQVtvqxRH/kFgBtGbqiGeHomzcvH8=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ openssl ];

  cargoSha256 = "sha256-Gfe3GmtGz4fwSxc8Ioa7tFZmrqJQLnFl0AqydySFguk=";
  buildAndTestSubdir = "cargo-smart-release";

  meta = with lib; {
    description = "Cargo subcommand for fearlessly releasing crates in workspaces.";
    homepage = "https://github.com/Byron/gitoxide";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ stupremee ];
  };
}
