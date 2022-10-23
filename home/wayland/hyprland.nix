{ inputs, system, pkgs, theme, ... }:
let
  inherit (builtins) concatStringsSep genList toString;

  pythonScratchpad = pkgs.writeShellScript "python-scratchpad" ''
    ${pkgs.python3}/bin/python3 -q
  '';

  hyprland = inputs.hyprland.packages."${system}".default.override {
    enableXWayland = true;
    nvidiaPatches = true;
  };
in
{

  home.packages = with pkgs; [
    # making screenshots
    slurp
    grim

    inputs.hyprland-contrib.packages.${system}.grimblast
    wlr-randr
    wl-clipboard
  ];

  programs.zsh.loginExtra = ''
    [ "$(tty)" = "/dev/tty1" ] && exec systemd-cat -t hyprland "${hyprland}/bin/Hyprland"
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland;

    systemdIntegration = true;

    xwayland.enable = true;
    xwayland.hidpi = true;

    recommendedEnvironment = true;

    extraConfig = ''
      # Monitor configuration
      monitor=HDMI-A-1,preferred,1920x0,1
      workspace=HDMI-A-1,1

      monitor=DP-2,preferred,0x0,1
      workspace=DP-2,10

      input {
        kb_layout eu
        follow_mouse=1
      }

      general {
        main_mod=SUPER

        gaps_in=5
        gaps_out=20
        border_size=2

        col.active_border=0xFF${theme.colors.base06}
        col.inactive_border=0xFF${theme.colors.base02}
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
      bind=SUPER,p,exec,$HOME/.config/rofi/bin/launcher
      bind=SUPER_SHIFT,p,exec,pkill .wofi || wofi -S run -I

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
          ws = if key == 0 then 10 else key;
        in ''
          bind=SUPER,${toString key},workspace,${toString ws}
          bind=SUPER,${toString key},movetoworkspacesilent,${toString ws}
        ''
      )
      10 )}

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
      bind=SUPER,s,exec,grimblast copysave area
      bind=SUPER_SHIFT,s,exec,grimblast copysave output

      # open python scratchpad
      bind=SUPER,o,exec,alacritty --title PythonScratchpad -e ${pythonScratchpad}

      # cycle monitors
      # , = left | . = right
      bind=SUPER,59,focusmonitor,l
      bind=SUPER,60,focusmonitor,r
    '';
  };
}
