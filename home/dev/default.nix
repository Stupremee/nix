{
  pkgs,
  unstable-pkgs,
  packages,
  ...
}: {
  imports = [./k8s.nix];

  home.packages = with pkgs;
    [
      unstable-pkgs.devenv
      httpie
      websocat
      numbat

      packages.tproxy
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux (with pkgs; [burpsuite dbeaver-bin]));

  home.sessionVariables = {
    SCCACHE_DIR = "/mnt/hdd/.sccache/";
  };
}
