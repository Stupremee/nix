{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.my.hyprland;

  keybind = key: mods: action: {inherit key mods action;};

  viKeybind = key: mods: action: {
    inherit key mods action;
    mode = "Vi";
  };

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

        disable = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };
in {
  options.my.hyprland = {
    enable = mkEnableOption "Enable configuration for hyprland window manager";

    sensitivity = mkOption {
      type = types.str;
      default = "1.0";
    };

    monitors = mkOption {
      type = types.attrsOf (types.submodule monitorOpts);
      default = {};
    };
  };

  config = mkIf cfg.enable {
    catppuccin.pointerCursor.enable = true;
    home.pointerCursor = {
      size = 24;
      gtk.enable = true;
    };

    gtk.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;

      systemd.variables = ["--all"];

      settings = {
        "$mod" = "SUPER";

        input = {
          kb_layout = "eu";
          follow_mouse = 1;
          sensitivity = cfg.sensitivity;
          accel_profile = "flat";
        };

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
            "$mod, Return, exec, alacritty"

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
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mod, code:1${toString i}, workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );

        monitor =
          mapAttrsToList (
            name: opts:
              if opts.disable
              then "${name},disable"
              else "${name},${opts.resolution},${opts.position},${opts.scale}"
          )
          cfg.monitors;
      };

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

      settings = {
        preload = "${../../wallpaper.png}";
        wallpaper =
          mapAttrsToList (
            name: _: "${name}, ${../../wallpaper.png}"
          )
          cfg.monitors;
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
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    programs.hyprlock = {
      enable = true;
    };
  };
}
