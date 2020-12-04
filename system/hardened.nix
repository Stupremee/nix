# Most of the options come from
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix

{ lib, ... }:
with lib; {
  nix.allowedUsers = mkDefault [ "@users" ];

  # These options make firefox segfaulting
  # environment.memoryAllocator.provider = mkDefault "scudo";
  # environment.variables.SCUDO_OPTIONS = mkDefault "ZeroContents=1";

  security.hideProcessInformation = mkDefault true;
  security.lockKernelModules = mkDefault true;
  security.protectKernelImage = mkDefault true;

  # security.apparmor.enable = mkDefault true;

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];
}
