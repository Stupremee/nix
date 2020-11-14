{ pkgs, ... }: {
  imports = [ ./shell ./gpg.nix ];

  # Alllow unfree packages.
  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  home.stateVersion = "20.09";
}
