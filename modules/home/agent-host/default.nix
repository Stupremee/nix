{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.agent-host;

  # Vite+ installs to XDG data on new hosts and ~/.vite-plus on older ones.
  userBinDirectories = [
    ".local/share/vite-plus/bin"
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
  # Enabled by the NixOS `my.agent-host` module, so hosts only toggle it once.
  options.my.agent-host = {
    enable = mkEnableOption "the home setup for running AI coding agents (t3code and friends)";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !any (package: hasPrefix "nodejs" (getName package)) config.home.packages;
        message = "Node.js on agent hosts must be managed by Vite+, not Home Manager.";
      }
    ];

    home = {
      packages = [ pkgs.python3 ];

      sessionPath = map (directory: "$HOME/${directory}") userBinDirectories;
    };

    systemd.user.sessionVariables.PATH = concatStringsSep ":" (
      map (directory: "${config.home.homeDirectory}/${directory}") userBinDirectories ++ [ "\${PATH}" ]
    );

    programs.zsh.initContent = mkAfter ''
      if [ -r "$HOME/.zshrc" ]; then
        source "$HOME/.zshrc"
      fi
    '';

    # Agent hosts have no YubiKey attached, so they sign with their passphrase-less SSH key,
    # registered as a signing key on GitHub.
    programs.git.signing = {
      format = "ssh";
      key = mkForce "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };

    my = {
      dev.enable = true;
      tmux.enable = mkForce false;
    };
  };
}
