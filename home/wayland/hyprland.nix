{
  inputs,
  system,
  pkgs,
  theme,
  lib,
  ...
}: let
  inherit (builtins) concatStringsSep genList toString;
  inherit (lib) removePrefix;

  pythonScratchpad = pkgs.writeShellScript "python-scratchpad" ''
    ${pkgs.python3}/bin/python3 -q
  '';

  hyprland = inputs.hyprland.packages."${system}".default.override {
    enableXWayland = true;
    nvidiaPatches = true;
    hidpiXWayland = true;
  };
in {
  home.packages = with pkgs; [
    # making screenshots
    slurp
    grim
    wf-recorder

    inputs.hyprland-contrib.packages.${system}.grimblast
    inputs.hyprpaper.packages.${system}.default
    wlr-randr
    wl-clipboard
    pciutils
    imv

    libsForQt5.polkit-kde-agent
  ];

  programs.zsh.loginExtra = ''
    [ "$(tty)" = "/dev/tty1" ] && exec systemd-cat -t hyprland "${hyprland}/bin/Hyprland"
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland;

    systemdIntegration = true;

    recommendedEnvironment = true;

    extraConfig = ''
      env = XDG_SESSION_TYPE,wayland
      env = WLR_NO_HARDWARE_CURSORS,1

      # Monitor configuration
      monitor=DP-2,2560x1440@144,0x0,1
      workspace=DP-2,1

      exec-once = hyprpaper
      exec-once = systemctl start --user eww.service && eww open bar --no-daemonize
      exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

      input {
        kb_layout=eu
        follow_mouse=1
        sensitivity=1.0
      }

      general {
        gaps_in=5
        gaps_out=20
        border_size=2

        col.active_border=0x88${removePrefix "#" theme.green}
        col.inactive_border=0x88${removePrefix "#" theme.overlay0}
      }

      decoration {
        rounding=5
      }

      animations {
        enabled=0
      }

      windowrulev2=float,class:pinentry-qt
      windowrulev2=center,class:pinentry-qt
      windowrulev2=pin,class:pinentry-qt

      windowrulev2=size 40%,title:PythonScratchpad
      windowrulev2=float,title:PythonScratchpad
      windowrulev2=center,title:PythonScratchpad
      windowrulev2=pin,title:PythonScratchpad

      bind=SUPER,Return,exec,$TERMINAL

      # application launcher
      bind=SUPER,p,exec,$HOME/.config/rofi/bin/launcher.sh
      bind=SUPER_SHIFT,p,exec,$HOME/.config/rofi/bin/runner.sh

      # compositor commands
      bind=SUPER,q,killactive,
      bind=SUPER,f,fullscreen,
      bind=SUPER_SHIFT,f,togglefloating,

      # move focus
      bind=SUPER,h,movefocus,l
      bind=SUPER,j,movefocus,d
      bind=SUPER,k,movefocus,u
      bind=SUPER,l,movefocus,r

      # move window
      bind=SUPER_SHIFT,h,movewindow,l
      bind=SUPER_SHIFT,j,movewindow,d
      bind=SUPER_SHIFT,k,movewindow,u
      bind=SUPER_SHIFT,l,movewindow,r

      # workspaces
      ${concatStringsSep "\n" (genList (
          key: let
            ws =
              if key == 0
              then 10
              else key;
          in ''
            bind=SUPER,${toString key},workspace,${toString ws}
            bind=SUPER_SHIFT,${toString key},movetoworkspacesilent,${toString ws}
          ''
        )
        10)}

      # window resize
      bind=SUPER,r,submap,resize

      submap=resize
      binde=,h,resizeactive,-10 0
      binde=,j,resizeactive,0 10
      binde=,k,resizeactive,0 -10
      binde=,l,resizeactive,10 0
      bind=,escape,submap,reset
      submap=reset

      # make screenshot
      bind=SUPER,s,exec,grimblast --notify copysave area
      bind=SUPER_SHIFT,s,exec,$HOME/.config/rofi/bin/screenshot.sh

      # power menu
      bind=SUPER,m,exec,$HOME/.config/rofi/bin/powermenu.sh

      # open python scratchpad
      bind=SUPER,o,exec,alacritty --title PythonScratchpad -e ${pythonScratchpad}

      # cycle monitors
      # , = left | . = right
      bind=SUPER,59,focusmonitor,l
      bind=SUPER,60,focusmonitor,r

      # dismiss notifications
      bind=CTRL,65,exec,makoctl dismiss
      bind=CTRL_SHIFT,65,exec,makoctl restore

      # media controls
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous
      bindl = , XF86AudioNext, exec, playerctl next
      # volume
      bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindle = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    '';
  };

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${theme.wallpaper}
    wallpaper = DP-2,${theme.wallpaper}
  '';
}
