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
    my.packages = with pkgs; [
      gcc
      bear
      gdb
      cmake

      llvmPackages.bintools
      llvmPackages.clang
      llvmPackages.clang-manpages
      llvmPackages.libcxx
      llvmPackages.llvm
    ];
  };
}
