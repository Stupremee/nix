{pkgs, ...}: {
  hardware.logitech.wireless.enable = true;

  environment.systemPackages = with pkgs; [
    solaar
  ];

  systemd.user.timers.check-mouse-battery = {
    description = "Regurlary check mouse battery level.";
    wantedBy = ["timers.target"];

    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "10m";
      Unit = "check-mouse-battery.service";
    };
  };

  systemd.user.services.check-mouse-battery = {
    description = "Check mouse battery level.";

    script = ''
      num=$(${pkgs.solaar}/bin/solaar show 'PRO X Wireless' | ${pkgs.ripgrep}/bin/rg -m 1 '\s+Battery: (\d{1,2})%.*' -r '$1')

      if [[ $num -lt 10 ]]; then
          ${pkgs.libnotify}/bin/notify-send -u critical -i mouse-battery-low "Mouse Battery low" "Mouse battery level is $num%"
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
    };
  };
}
