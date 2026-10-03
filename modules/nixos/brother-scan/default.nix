{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.brother-scan;

  home = config.users.users.${cfg.user}.home;
  port = 54925;
in
{
  options.my.brother-scan = {
    enable = mkEnableOption "Brother \"Scan to PC\" receiver that saves button-triggered scans as PDFs";

    printerAddress = mkOption {
      type = types.str;
      description = "IP address of the Brother scanner";
    };

    model = mkOption {
      type = types.str;
      description = "Scanner model as known to brscan4, e.g. MFC-L2710DW";
    };

    hostAddress = mkOption {
      type = types.str;
      description = "IP address of this host as reachable from the scanner";
    };

    targetName = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "Name shown as scan destination on the scanner display";
    };

    user = mkOption {
      type = types.str;
      default = "stu";
      description = "User that owns the scans and runs the hooks";
    };
  };

  config = mkIf cfg.enable {
    hardware.sane = {
      enable = true;
      brscan4 = {
        enable = true;
        netDevices.scanner = {
          inherit (cfg) model;
          ip = cfg.printerAddress;
        };
      };
    };

    # Only the scanner may send button notifications.
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p udp -s ${cfg.printerAddress} --dport ${toString port} -j nixos-fw-accept
    '';

    # Scans land in ~/scans/scan_<date>_<time>.pdf. After each scan every *.sh in
    # ~/.config/brother-scan/hooks.d runs as the user with the PDF path as $1.
    systemd.services.brother-scan = {
      description = "Brother Scan to PC receiver";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      path = with pkgs; [
        sane-backends
        net-snmp
        img2pdf
        bash
        # Give hooks the same tools as a login shell.
        "/etc/profiles/per-user/${cfg.user}"
        "/run/current-system/sw"
      ];

      environment = {
        PRINTER = cfg.printerAddress;
        HOST_IP = cfg.hostAddress;
        TARGET_NAME = cfg.targetName;
        OUT_DIR = "${home}/scans";
        HOOKS_DIR = "${home}/.config/brother-scan/hooks.d";
        # Same SANE setup the hardware.sane module gives login sessions.
        SANE_CONFIG_DIR = "/etc/sane-config";
        LD_LIBRARY_PATH = "/etc/sane-libs";
      };

      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 -u ${./brother-scan.py}";
        User = cfg.user;
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
