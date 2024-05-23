{
  source,
  buildGoModule,
}:
buildGoModule rec {
  inherit (source) pname version src;

  vendorHash = "sha256-7s2gnd9UR/R7H5pcA8NcoenaabSVpMh3qzzkOr5RWnU=";

  ldflags = [
    "-w"
    "-s"
  ];
}
