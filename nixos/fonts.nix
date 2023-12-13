{
  pkgs,
  unstable-pkgs,
  ...
}: {
  fonts = {
    packages = let
      nerdFont = unstable-pkgs.nerdfonts.override {
        fonts = ["Monaspace"];
      };
    in
      with pkgs; [
        nerdFont
        monaspace
      ];

    enableDefaultPackages = false;

    fontconfig.defaultFonts = {
      # serif = ["MonaspiceXe Nerd Font"];
      # sansSerif = ["MonaspiceAr Nerd Font"];
      monospace = ["MonaspiceNe Nerd Font Mono"];
    };
  };
}
