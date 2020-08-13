{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.media.spotify = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.media.spotify.enable {
    my.packages = with pkgs; [
      spotifyd
      (writeScriptBin "spt" ''
        #!${stdenv.shell}
        if ! systemctl --user is-active spotifyd >/dev/null; then
          systemctl --user start spotifyd
        fi
        echo $TMUX >/tmp/spt.tmux
        exec ${spotify-tui}/bin/spt
      '')

      playerctl

      (writeScriptBin "spt-send-notify" ''
         #!${stdenv.shell}
         client_id=$(pass Spotify.com | grep -E '^client_id:' | awk '{print $2}')
         client_secretd=$(pass Spotify.com | grep -E '^client_secret:' | awk '{print $2}')
         jq="${pkgs.jq}/bin/jq"
      '')
    ];

    systemd.user.services.spotifyd.serviceConfig = 
      let spotifydConf = pkgs.writeText "spotifyd.conf" ''
          [global]
          username = juklkliem
          password_cmd = ${pkgs.pass}/bin/pass Spotify.com | head -n1
          backend = pulseaudio
          on_song_change_hook = spt-send-notify
          cache_path = /home/${config.my.username}/.cache/spotifyd
        '';
      in {
        ExecStart = ''
          ${pkgs.spotifyd}/bin/spotifyd --no-daemon \
                                                 --cache-path /tmp/spotifyd \
                                                 --config-path ${spotifydConf}
        '';
        Restart = "always";
        RestartSec = 6;
      };
  };
}
