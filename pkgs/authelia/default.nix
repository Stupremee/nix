{
  source,
  sources,
  buildGoModule,
}:
buildGoModule {
  inherit (source) pname version src;

  patchPhase = ''
    cp -r ${sources.authelia-web.src}/* ./internal/server/public_html/
  '';

  doCheck = false;

  subPackages = ["./cmd/authelia"];

  ldflags = [
    "-linkmode=external"
    "-s"
    "-w"
  ];

  vendorHash = "sha256-mzGE/T/2TT4+7uc2axTqG3aeLMnt1r9Ya7Zj2jIkw/w=";
}
