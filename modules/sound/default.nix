{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.my.sound;
in {
  options.my.sound = {
    enable = mkEnableOption "Enable default sound settings";
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = false;

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      wireplumber.enable = true;

      jack.enable = true;
      pulse.enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
      pulsemixer
    ];

    users.extraUsers.${config.my.user.mainUser}.extraGroups = ["audio"];
  };
}
