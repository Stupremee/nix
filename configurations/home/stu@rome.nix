{
  config,
  lib,
  pkgs,
  ...
}:
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

    sessionPath = [
      "$HOME/.vite-plus/bin"
      "$HOME/.local/bin"
      "$HOME/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
      "$HOME/.bun/bin"
      "$HOME/.local/share/pnpm"
    ];
  };

  my.dev.enable = true;
}
