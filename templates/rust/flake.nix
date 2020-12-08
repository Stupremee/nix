{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    naersk-lib.url = "github:nmattia/naersk";
    mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, naersk-lib, mozilla }:
    utils.lib.eachDefaultSystem (system:
      let
        manifest = builtins.fromTOML (builtins.readFile ./Cargo.toml);
        version = manifest.package.version;
        pname = manifest.package.name;

        pkgs = nixpkgs.legacyPackages."${system}";

        mozpkgs = pkgs.callPackage (mozilla + "/package-set.nix") { };
        rustChannel = mozpkgs.latest.rustChannels.stable;
        rust = rustChannel.rust;

        naersk = naersk-lib.lib."${system}".override {
          cargo = rust;
          rustc = rust;
        };

        pkg = naersk.buildPackage {
          inherit pname version;
          src = ./.;
          root = ./.;
          copyBins = true;
          copyLibs = false;
          release = true;
        };
      in {
        # `nix build`
        packages."${pname}" = pkg;
        defaultPackage = self.packages."${pname}";

        # `nix run`
        apps."${pname}" = utils.lib.mkApp { drv = self.packages."${pname}"; };
        defaultApp = self.apps."${pname}";

        # `nix develop`
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            (rust.override { extensions = [ "rust-src" ]; })
            pkgs.rust-analyer
          ];
        };
      });
}
