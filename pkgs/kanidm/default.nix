{
  stdenv,
  lib,
  formats,
  nixosTests,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  udev,
  openssl,
  sqlite,
  pam,
  zlib,
  source,
  rust-bin,
  makeRustPlatform,
}: let
  arch =
    if stdenv.isx86_64
    then "x86_64"
    else "generic";

  rustPlatform = makeRustPlatform {
    cargo = rust-bin.stable.latest.minimal;
    rustc = rust-bin.stable.latest.minimal;
  };
in
  rustPlatform.buildRustPackage rec {
    inherit (source) pname version src;

    # cargoLock = source.cargoLock."Cargo.lock";
    cargoSha256 = "sha256-8OwL1cnBkFRX4E5Vxy4NJiSunu3vvzSlswJVzAPUxe4=";

    KANIDM_BUILD_PROFILE = "release_nixos_${arch}";

    postPatch = let
      format = (formats.toml {}).generate "${KANIDM_BUILD_PROFILE}.toml";
      profile = {
        web_ui_pkg_path = "@web_ui_pkg_path@";
        cpu_flags =
          if stdenv.isx86_64
          then "x86_64_v1"
          else "none";
      };
    in ''
      cp ${format profile} profiles/${KANIDM_BUILD_PROFILE}.toml
      substituteInPlace profiles/${KANIDM_BUILD_PROFILE}.toml \
        --replace '@web_ui_pkg_path@' "$out/ui"
    '';

    nativeBuildInputs = [
      pkg-config
      installShellFiles
    ];

    buildInputs =
      [
        openssl
        sqlite
        pam
        zlib
      ]
      ++ (lib.optionals stdenv.isLinux [udev]);

    # The UI needs to be in place before the tests are run.
    postBuild = ''
      # We don't compile the wasm-part form source, as there isn't a rustc for
      # wasm32-unknown-unknown in nixpkgs yet.
      mkdir $out
      cp -r kanidmd_web_ui/pkg $out/ui
    '';

    preFixup = ''
      installShellCompletion \
        --bash $releaseDir/build/completions/*.bash \
        --zsh $releaseDir/build/completions/_*
      # PAM and NSS need fix library names
      mv $out/lib/libnss_kanidm.so $out/lib/libnss_kanidm.so.2
      mv $out/lib/libpam_kanidm.so $out/lib/pam_kanidm.so
    '';
  }
