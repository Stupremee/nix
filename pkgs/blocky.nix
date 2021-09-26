{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "blocky";
  version = "0.16";

  src = fetchFromGitHub {
    owner = "0xERR0R";
    repo = "blocky";
    rev = "v${version}";
    sha256 = "sha256-7ACiQbnHE4UgxXFG6SmAAvTUZD5p1nUvKVAeDSdXLBE=";
  };

  vendorSha256 = "sha256-a9YDIpCJ2FeTm1JfKcgGQR5+wcJHxKcsgV/PAIEielk=";

  doCheck = false;

  ldflags = "-w -s -X github.com/0xERR0R/blocky/util.Version=${version}";
}
