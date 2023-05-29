{
  inputs,
  system,
  lib,
  pkgs,
  theme,
  config,
  ...
}: let
  eww = inputs.eww.packages."${system}".eww-wayland;

  deps = with pkgs; [
    config.wayland.windowManager.hyprland.package
    config.services.mako.package
    bash
    gojq
    gnused
    findutils
    socat
    coreutils
    systemd
    jq
    ripgrep
    gawk
    bc
    procps
    wireplumber
    pulseaudio
    pavucontrol
    playerctl
    wget
  ];
in {
  xdg.configFile."eww" = {
    recursive = true;
    source = lib.cleanSourceWith {
      filter = name: _: !(lib.hasSuffix ".nix" name);
      src = lib.cleanSource ./.;
    };
  };

  home.packages = [eww];

  systemd.user.services.eww = {
    Unit = {
      Description = "Eww Daemon";
    };

    Service = {
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath deps}";
      ExecStart = "${eww}/bin/eww daemon --no-daemonize";
    };
  };

  xdg.configFile."eww/css/_colors.scss".text = ''
    $rosewater:   ${theme.rosewater};
    $flamingo:    ${theme.flamingo};
    $pink:        ${theme.pink};
    $mauve:       ${theme.mauve};
    $red:         ${theme.red};
    $maroon:      ${theme.maroon};
    $peach:       ${theme.peach};
    $yellow:      ${theme.yellow};
    $green:       ${theme.green};
    $teal:        ${theme.teal};
    $sky:         ${theme.sky};
    $sapphire:    ${theme.sapphire};
    $blue:        ${theme.blue};
    $lavender:    ${theme.lavender};

    $text:        ${theme.text};
    $subtext1:    ${theme.subtext1};
    $subtext0:    ${theme.subtext0};
    $overlay2:    ${theme.overlay2};
    $overlay1:    ${theme.overlay1};
    $overlay0:    ${theme.overlay0};

    $surface2:    ${theme.surface2};
    $surface1:    ${theme.surface1};
    $surface0:    ${theme.surface0};

    $base:        ${theme.base};
    $mantle:      ${theme.mantle};
    $crust:       ${theme.crust};

    $fg: $text;
    $bg: $base;
    $bg1: $surface0;
    $border: #28283d;
    $shadow: $crust;
  '';
}
