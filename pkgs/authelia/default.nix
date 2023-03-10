{
  source,
  buildGoModule,
}:
buildGoModule {
  inherit (source) pname version src;

  doCheck = false;

  vendorHash = "sha256-mzGE/T/2TT4+7uc2axTqG3aeLMnt1r9Ya7Zj2jIkw/w=";
}
