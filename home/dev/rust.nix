{ pkgs, ... }: {
  home.packages = with pkgs; [ cargo-edit ];

  programs.zsh.shellAliases.ncargo = "env -u CARGO_TARGET_DIR cargo";
}
