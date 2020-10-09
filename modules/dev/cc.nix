{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.dev.cc = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.cc.enable {
    my = {
      packages = with pkgs; [
        gcc
        bear
        gdb
        cmake
        pkgconfig

        llvmPackages_10.bintools
        llvmPackages_10.libclang
        llvmPackages_10.clang
        llvmPackages_10.clang-manpages
        llvmPackages_10.libcxx
        llvmPackages_10.llvm
      ];
      zsh.env = ''
        export LIBCLANG_PATH=${pkgs.llvmPackages.libclang}/lib
      '';
    };
  };
}
