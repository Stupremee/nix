{
  config,
  lib,
  pkgs,
  ...
}:
let
  userBinDirectories = [
    ".vite-plus/bin"
    ".local/bin"
    "bin"
    ".cargo/bin"
    "go/bin"
    ".bun/bin"
    ".local/share/pnpm"
  ];
in
{
  catppuccin.flavor = "latte";

  assertions = [
    {
      assertion = !lib.any (package: lib.hasPrefix "nodejs" (lib.getName package)) config.home.packages;
      message = "Node.js on Rome must be managed by Vite+, not Home Manager.";
    }
  ];

  home = {
    packages = [ pkgs.python3 ];

    sessionPath = map (directory: "$HOME/${directory}") userBinDirectories;
  };

  systemd.user.sessionVariables.PATH = lib.concatStringsSep ":" (
    map (directory: "${config.home.homeDirectory}/${directory}") userBinDirectories ++ [ "\${PATH}" ]
  );

  programs.zsh.initContent = lib.mkAfter ''
    if [ -r "$HOME/.zshrc" ]; then
      source "$HOME/.zshrc"
    fi
  '';

  programs.git.signing = {
    key = lib.mkForce null;
    signByDefault = lib.mkForce false;
  };

  my = {
    dev.enable = true;
    tmux.enable = lib.mkForce false;
  };
}
