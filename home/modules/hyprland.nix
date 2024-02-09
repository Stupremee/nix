{
  config,
  inputs,
  system,
  pkgs,
  unstable-pkgs,
  theme,
  lib,
  ...
}: let
  cfg = config.modules.hyprland;

  monitorOpts = {...}:
    with lib; {
      options = {
        position = mkOption {
          type = types.str;
          default = "0x0";
        };

        resolution = mkOption {
          type = types.str;
          default = "preferred";
        };

        scale = mkOption {
          type = types.str;
          default = "1";
        };
      };
    };

  deviceOpts = {...}:
    with lib; {
      options = {
        kbOptions = mkOption {
          type = types.nullOr types.str;
          default = null;
        };

        sensitivity = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
    };
in {
  options.modules.hyprland = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    devices = mkOption {
      type = types.attrsOf (types.submodule deviceOpts);
      default = {};
    };

    monitors = mkOption {
      type = types.attrsOf (types.submodule monitorOpts);
      default = {};
    };

    sensitivity = mkOption {
      type = types.str;
      default = "1.0";
    };
  };

  config = let
    inherit (builtins) concatStringsSep genList toString;
    inherit (lib) removePrefix;

    pythonScratchpad = pkgs.writeShellScript "python-scratchpad" ''
      ${pkgs.numbat}/bin/numbat
    '';
  in
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        # making screenshots
        slurp
        grim
        wf-recorder

        inputs.hyprland-contrib.packages.${system}.grimblast
        (inputs.hyprpaper.packages.${system}.default.overrideAttrs (old: {
          buildInputs = old.buildInputs ++ (with unstable-pkgs; [libGL]);
        }))
        wlr-randr
        wl-clipboard
        pciutils
        imv

        libsForQt5.polkit-kde-agent
      ];

      programs.zsh.loginExtra = ''
        [ "$(tty)" = "/dev/tty1" ] && exec systemd-cat -t hyprland "Hyprland"
      '';

      wayland.windowManager.hyprland = {
        enable = true;

        systemd.enable = true;

        extraConfig = let
          inherit (lib) mapAttrsToList;

          monitorList =
            mapAttrsToList (name: opts: ''
              monitor=${name},${opts.resolution},${opts.position},${opts.scale}
            '')
            cfg.monitors;

          monitorsConfig = builtins.concatStringsSep "" monitorList;

          devicesList =
            mapAttrsToList (name: opts: let
              kbOptions =
                if opts.kbOptions != null
                then "kb_options=${opts.kbOptions}"
                else "";

              sensitivity =
                if opts.sensitivity != null
                then "sensitivity=${opts.sensitivity}"
                else "";
            in ''
              device:${name} {
                ${kbOptions}
                ${sensitivity}
              }
            '')
            cfg.devices;

          devicesConfig = builtins.concatStringsSep "" devicesList;
        in ''
          env = XDG_SESSION_TYPE,wayland
          env = WLR_NO_HARDWARE_CURSORS,1

          # Monitor configuration
          ${monitorsConfig}

          exec-once = hyprpaper
          exec-once = systemctl start --user eww.service && eww open bar --no-daemonize
          exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

          ${devicesConfig}

          input {
            kb_layout=eu
            follow_mouse=1
            sensitivity=${cfg.sensitivity}
            force_no_accel
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

          # lock laptop
          bind=SUPER_SHIFT,x,exec,swaylock

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

      xdg.configFile."hypr/hyprpaper.conf".text = let
        inherit (lib) mapAttrsToList;

        additional = mapAttrsToList (mon: _: "wallpaper = ${mon},${theme.wallpaper}") cfg.monitors;
      in ''
        preload = ${theme.wallpaper}
        ${concatStringsSep "\n" additional}
      '';
    };
}
