{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.agent-host;
in
{
  options.my.agent-host = {
    enable = mkEnableOption "the setup for hosts that run AI coding agents (t3code and friends) as the main user";
  };

  config = mkIf cfg.enable {
    # Agents install prebuilt binaries (Playwright browsers, Electron, language servers) that
    # expect an FHS system.
    programs.nix-ld = {
      enable = true;

      libraries = with pkgs; [
        alsa-lib
        atk
        at-spi2-core
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        glib
        gtk3
        libdrm
        libgbm
        libxkbcommon
        mesa
        nspr
        nss
        pango
        systemd

        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxcb
      ];
    };

    environment.etc."ssl/cert.pem".source = "/etc/ssl/certs/ca-certificates.crt";

    # Allow the main user to run tailscale commands without sudo
    services.tailscale.extraSetFlags = [ "--operator=${config.my.user.mainUser}" ];

    home-manager = {
      backupFileExtension = "hm-backup";
      users.${config.my.user.mainUser}.my.agent-host.enable = true;
    };

    # Runaway agents and dev servers must never lock us out. Everything the main user's systemd
    # instance runs (t3code, agents, and all their children) shares one budget, while
    # tailscaled, sshd and interactive SSH sessions stay outside it. Test with
    # `systemd-run --user stress-ng --vm 8 --vm-bytes 100% --cpu 16`, then SSH in.
    systemd.services."user@${toString config.users.users.${config.my.user.mainUser}.uid}" = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        MemoryHigh = "75%";
        # OOM kills happen inside the budget instead of system-wide
        MemoryMax = "85%";
        # Both hosts have 16G of swap; leave some for the system
        MemorySwapMax = "12G";
        # Lose to system services and SSH sessions under contention, use everything when idle
        CPUWeight = 20;
        IOWeight = 20;
        TasksMax = 8192;
      };
    };

    # When the kernel OOM-kills one runaway child, keep its service (t3code) running instead
    # of stopping it
    systemd.user.extraConfig = "DefaultOOMPolicy=continue";

    # Keep the way in responsive: system services' memory is never reclaimed or swapped out for
    # the budget above, and tailscaled is never chosen by the OOM killer
    systemd.slices.system.sliceConfig.MemoryMin = "2G";
    systemd.services.tailscaled.serviceConfig.OOMScoreAdjust = -1000;
  };
}
