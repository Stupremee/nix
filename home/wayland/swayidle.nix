{
  pkgs,
  lib,
  ...
}: let
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
in {
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${swaylock} -f";
      }
      {
        event = "lock";
        command = "${swaylock} -f";
      }
    ];

    timeouts = [
      {
        timeout = 300;
        command = "${swaylock} -f";
      }
    ];
  };

  systemd.user.services.swayidle = {
    Install.WantedBy = lib.mkForce ["hyprland-session.target"];

    # fix that is not backported to home-manager/release-22.05
    Service.Environment = [
      "PATH=${lib.makeBinPath [pkgs.bash]}"
    ];
  };
}
