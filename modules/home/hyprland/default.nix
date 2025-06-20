{
  lib,
  config,
  flake,
  pkgs,
  theme,
  ...
}:
with lib;
let
  inherit (flake.inputs) self;

  cfg = config.my.hyprland;

  monitorOpts =
    _: with lib; {
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

        disable = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };

  pythonScratchpad = pkgs.writeShellScript "python-scratchpad" ''
    ${pkgs.numbat}/bin/numbat
  '';
in
{
  options.my.hyprland = {
    enable = mkEnableOption "Enable configuration for hyprland window manager";

    terminal = mkOption {
      type = types.str;
    };

    sensitivity = mkOption {
      type = types.str;
      default = "1.0";
    };

    swap-escape-caps = mkOption {
      type = types.bool;
      default = false;
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
    };

    monitors = mkOption {
      type = types.attrsOf (types.submodule monitorOpts);
      default = { };
    };

    hyprpanel = {
      settings = mkOption {
        type = types.attrs;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    catppuccin.cursors.enable = true;
    home = {
      pointerCursor = {
        size = 16;
        gtk.enable = true;
      };

      packages = with pkgs; [
        grimblast
        wf-recorder
        wl-clipboard
        imv
        mpv
      ];
    };

    gtk.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;

      systemd.variables = [ "--all" ];

      settings = {
        "$mod" = "SUPER";

        input = {
          inherit (cfg) sensitivity;
          kb_layout = "eu";
          follow_mouse = 1;
          accel_profile = "flat";
        };

        animations.enabled = 0;

        env = [
          "HYPRCURSOR_SIZE,16"
        ];

        exec-once = [
          "hyprctl setcursor HYPRCURSOR_SIZE 16"
        ];

        windowrulev2 = [
          "float,class:pinentry-qt"
          "center,class:pinentry-qt"
          "pin,class:pinentry-qt"

          "size 40%,title:PythonScratchpad"
          "float,title:PythonScratchpad"
          "center,title:PythonScratchpad"
          "pin,title:PythonScratchpad"
        ];

        bind =
          [
            "$mod, Return, exec, ${cfg.terminal}"

            # compositor commands
            "$mod, q, killactive"
            "$mod, f, fullscreen"
            "$mod SHIFT, f, togglefloating"

            # move focus
            "$mod, h, movefocus, l"
            "$mod, j, movefocus, d"
            "$mod, k, movefocus, u"
            "$mod, l, movefocus, r"

            # move window
            "$mod SHIFT, h, movewindow, l"
            "$mod SHIFT, j, movewindow, d"
            "$mod SHIFT, k, movewindow, u"
            "$mod SHIFT, l, movewindow, r"

            # Start application launcher
            "$mod, p, exec, rofi-launcher"
            "$mod_SHIFT, p, exec, rofi-runner"

            "$mod, m, exec, rofi-powermenu"

            # Making screenshots
            "$mod, s, exec, grimblast --notify copysave area"
            "$mod_SHIFT, s, exec, rofi-screenshot"

            # dismiss notifications
            "ctrl, 65, exec, makoctl dismiss"
            "ctrl_shift, 65, exec, makoctl restore"

            # lock screen
            "$mod_SHIFT, x, exec, hyprlock"

            # Python scratchpad
            "$mod, o, exec, ${cfg.terminal} --title PythonScratchpad -e ${pythonScratchpad}"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (
              builtins.genList (
                i:
                let
                  ws = i + 1;
                in
                [
                  "$mod, code:1${toString i}, workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              ) 9
            )
          );

        bindl = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];

        bindel = [
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
        ];

        monitor = mapAttrsToList (
          name: opts:
          if opts.disable then
            "${name},disable"
          else
            "${name},${opts.resolution},${opts.position},${opts.scale}"
        ) cfg.monitors;
      } // cfg.extraSettings;

      extraConfig = ''
        submap=resize
        binde=,h,resizeactive,-10 0
        binde=,j,resizeactive,0 10
        binde=,k,resizeactive,0 -10
        binde=,l,resizeactive,10 0
        bind=,escape,submap,reset
        submap=reset
      '';
    };

    services.hyprpaper = {
      enable = true;

      settings =
        let
          wallpaper = flake.inputs.self + /assets/wallpaper.png;
        in
        {
          preload = wallpaper;
          wallpaper = mapAttrsToList (name: _: "${name}, ${wallpaper}") cfg.monitors;
        };
    };

    services.hypridle = {
      enable = true;

      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 120;
            on-timeout = "hyprlock";
          }
          {
            timeout = 300;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    programs.hyprlock = {
      enable = true;

      settings = {
        general = {
          disable_loading_bar = true;
          immediate_render = true;
          hide_cursor = false;
          no_fade_in = true;
        };

        background = [
          {
            monitor = "";
            path = self + /assets/wallpaper.png;
            blur_passes = 3;
            blur_size = 12;
            noise = "0.1";
            contrast = "1.3";
            brightness = "0.2";
            vibrancy = "0.5";
            vibrancy_darkness = "0.3";
          }
        ];

        input-field = [
          {
            monitor = "eDP-1";

            size = "300, 50";
            valign = "bottom";
            position = "0%, 10%";

            outline_thickness = 1;

            font_color = "rgb(b6c4ff)";
            outer_color = "rgba(180, 180, 180, 0.5)";
            inner_color = "rgba(200, 200, 200, 0.1)";
            check_color = "rgba(247, 193, 19, 0.5)";
            fail_color = "rgba(255, 106, 134, 0.5)";

            fade_on_empty = false;
            placeholder_text = "Enter Password";

            dots_spacing = 0.2;
            dots_center = true;
            dots_fade_time = 100;

            shadow_color = "rgba(0, 0, 0, 0.1)";
            shadow_size = 7;
            shadow_passes = 2;
          }
        ];

        label = [
          {
            monitor = "";
            text = ''
              cmd[update:1000] echo "<span font-weight='ultralight' >$(date +'%H %M %S')</span>"
            '';
            font_size = 300;
            font_family = "monospace";

            color = "rgb(b6c4ff)";

            position = "0%, 2%";

            valign = "center";
            halign = "center";

            shadow_color = "rgba(0, 0, 0, 0.1)";
            shadow_size = 20;
            shadow_passes = 2;
            shadow_boost = 0.3;
          }
        ];
      };
    };

    programs.hyprpanel = {
      enable = true;
      systemd.enable = true;
      hyprland.enable = true;
      overwrite.enable = true;

      settings = {
        inherit (config.my.hyprland) terminal;

        menus = {
          clock.weather = {
            unit = "metric";
            location = "Leipzig";
          };
        };

        bar = {
          launcher.autoDetectIcon = true;
          customModules.weather.unit = "metric";
          workspaces.show_numbered = true;
        };

        theme = {
          bar.transparent = true;

          name = "catppuccin_${config.catppuccin.flavor}";

          font = {
            name = "Monaspace Neon Light";
            size = "16px";
          };
        };
      } // cfg.hyprpanel.settings;
    };
  };
}
