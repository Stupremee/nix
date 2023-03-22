{
  source,
  vimUtils,
  fetchzip,
  system,
}: let
  tabnineBundleVersion = "4.4.273";

  tabnineTarget =
    if system == "x86_64-linux"
    then "x86_64-unknown-linux-musl"
    else if system == "aarch64-darwin"
    then "aarch64-apple-darwin"
    else throw "No supported tabnine target";

  tabninePath = "${tabnineBundleVersion}/${tabnineTarget}";

  tabnineBinaries = fetchzip {
    url = "https://update.tabnine.com/bundles/${tabninePath}/TabNine.zip";
    stripRoot = false;
    sha256 = "sha256-FhtGEJWVDvqW/nsLv2RTYsgOi26IMkpbzyaSsH/lPuQ=";
  };
in
  vimUtils.buildVimPluginFrom2Nix {
    inherit (source) pname version src;

    dontPatchShebangs = true;

    patchPhase = ''
      mkdir -p $out/binaries/${tabninePath}
      cp ${tabnineBinaries}/* $out/binaries/${tabninePath}/
      chmod +x $out/binaries/${tabninePath}/*
    '';
  }
