{ pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override { enableVaapi = true; };
  };
}
