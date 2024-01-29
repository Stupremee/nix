{
  source,
  buildGoModule,
}:
buildGoModule rec {
  inherit (source) pname version src;

  vendorHash = "sha256-tnVzX0crDdkRND7Au0CaTdmwLVxVjxU1jxCRutl48S8=";

  ldflags = [
    "-w"
    "-s"
  ];
}
