{ pkgs, ... }: {
  packages = {
    grimblast = pkgs.callPackage ./grimblast { };
  };
}
