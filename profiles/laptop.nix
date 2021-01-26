# Various configurations that can mostly be applied
# to every laptop device.
{ ... }: {
  environment.systemPackages = with pkgs; [ acpi lm_sensors pciutils usbutils ];

  hardware.bluetooth.enable = true;

  # `light` command line tool to control the backlight.
  programs.light.enable = true;
  # Make function keys for backlight control work
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -A 5";
      }
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -U 5";
      }
    ];
  };

  # Enable media keys
  sound.mediaKeys = lib.mkIf (!config.hardware.pulseaudio.enable) {
    enable = true;
    volumeStep = "1dB";
  };

  # Seems to be better
  services.chrony.enable = true;
  services.timesyncd.enable = false;

  # Better power management
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_HWP_ON_AC = "performance";
  };
}
