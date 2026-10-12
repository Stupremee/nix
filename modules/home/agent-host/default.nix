{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.agent-host;

  # Local wrappers take priority over binaries installed by CLI tools.
  # Vite+ installs to XDG data on new hosts and ~/.vite-plus on older ones.
  userBinDirectories = [
    ".local/bin"
    ".local/share/vite-plus/bin"
    ".vite-plus/bin"
    "bin"
    ".cargo/bin"
    "go/bin"
    ".bun/bin"
    ".local/share/pnpm"
  ];

  restoreUserBinPath = ''
    typeset -U path
    path=( ${
      concatMapStringsSep " " (directory: ''"$HOME/${directory}"'') userBinDirectories
    } "''${path[@]}" )
    export PATH
  '';
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

      sessionPath = mkBefore (map (directory: "$HOME/${directory}") userBinDirectories);
    };

    # NixOS sets the base PATH in 50-systemd-path.conf, after Home Manager's defaults.
    xdg.configFile."environment.d/60-agent-host-path.conf".text = ''
      PATH=${
        concatStringsSep ":" (
          map (directory: "${config.home.homeDirectory}/${directory}") userBinDirectories ++ [ "\${PATH}" ]
        )
      }
    '';

    programs.zsh = {
      envExtra = mkAfter restoreUserBinPath;
      initContent = mkAfter ''
        if [ -r "$HOME/.zshrc" ]; then
          source "$HOME/.zshrc"
        fi

        # CLI installers may prepend their own directories in ~/.zshrc.
        ${restoreUserBinPath}
      '';
    };

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
