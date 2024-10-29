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

  monitor =
    mapAttrsToList (
      name: opts:
        if opts.disable
        then "${name},disable"
        else "${name},${opts.resolution},${opts.position},${opts.scale}"
    )
    cfg.monitors;
in {
  options.my.hyprland = {
    enable = mkEnableOption "Enable configuration for hyprland window manager";

    monitors = mkOption {
      type = types.attrsOf (types.submodule monitorOpts);
      default = {};
    };
  };

  config = mkIf cfg.enable {
    gtk.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        inherit monitor;

        "$mod" = "SUPER";

        input = {
          kb_layout = "eu";
          follow_mouse = 1;
          sensitivity = "1.0";
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
            "$mod, Return, exec, $TERMINAL"

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
  };
}
