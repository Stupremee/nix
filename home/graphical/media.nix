{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    pavucontrol
    playerctl
    pulsemixer
    imv
    spotify-tui
  ];

  services.playerctld.enable = true;

  programs.mpv = {
    enable = true;
    defaultProfiles = ["gpu-hq"];
    scripts = [pkgs.mpvScripts.mpris];
  };

  # age.secrets.spotify.file = ../../secrets/spotify;
  #
  # services.spotifyd = {
  #   enable = true;
  #   package = pkgs.spotifyd.override {withMpris = true;};
  #   settings.global = {
  #     autoplay = true;
  #     backend = "pulseaudio";
  #     bitrate = 320;
  #     cache_path = "${config.xdg.cacheHome}/spotifyd";
  #     device_type = "computer";
  #     use_mpris = true;
  #     volume_normalisation = true;
  #     username_cmd = "head -1 ${config.age.secrets.spotify.path}";
  #     password_cmd = "tail -1 ${config.age.secrets.spotify.path}";
  #   };
  # };
}
