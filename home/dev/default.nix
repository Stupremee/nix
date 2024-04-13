{
  pkgs,
  unstable-pkgs,
  packages,
  ...
}: {
  imports = [./k8s.nix];

  home.packages = with pkgs;
    [
      dbeaver
      unstable-pkgs.devenv
      httpie
      websocat
      numbat

      packages.tproxy
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [pkgs.burpsuite]);

  home.sessionVariables = {
    SCCACHE_DIR = "/mnt/hdd/.sccache/";
  };
}
