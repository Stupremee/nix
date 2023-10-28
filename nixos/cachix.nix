{pkgs, ...}: {
  environment.systemPackages = with pkgs; [cachix];
  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
        # "https://cache.mainframe.lan"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        # "cache.mainframe.lan-1:aY+8M6ACH05aIHhoXFzNbqmN/xy/D9UpSv3UAKhpFIo="
      ];
    };
  };
}
