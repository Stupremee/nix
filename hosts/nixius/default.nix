{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../../hardware/nvidia.nix
    ../../hardware/yubico.nix
    ../../hardware/wacom.nix
    ../../desktop
    ../../system
  ];

  nixpkgs.config.allowUnfree = true;

  # programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "usbmon" "uvcvideo" ];

  # Increase the locked memory limit
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      type = "hard";
      value = 512;
    }
    {
      domain = "*";
      item = "memlock";
      type = "soft";
      value = 512;
    }
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.unstable.wireshark;
  };

  users.users.stu = {
    isNormalUser = true;
    extraGroups =
      [ "wheel" "audio" "docker" "disk" "networkmanager" "wireshark" ];
    shell = pkgs.zsh;
  };
  nix.trustedUsers = [ "root" "stu" ];

  services.xserver = {
    windowManager.bspwm.enable = true;

    displayManager.lightdm = {
      greeters.mini.user = "stu";
      greeters.mini.extraConfig = ''
        text-color = "#a3be8c"
        password-background-color = "#2e3440"
        window-color = "#4c566a"
        border-color = "#4c566a"
      '';
    };

    displayManager.defaultSession = "none+bspwm";
    displayManager.setupCommands = ''
      ${pkgs.xlibs.xrandr}/bin/xrandr --output DP-3 --auto --left-of HDMI-0
    '';

    xrandrHeads = [
      {
        output = "HDMI-0";
        primary = true;
      }
      "DP-3"
    ];
  };

  programs.dconf.enable = true;
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.stu = import ../../home/stu.nix;
  };

  # Hardware cofiguration
  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.fwupd.enable = true;

  # Boot configuration
  boot.tmpOnTmpfs = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;

  services.smartd.enable = true;
  services.smartd.notifications.x11.enable = true;

  services.resolved.enable = true;

  # Netowrking configuration
  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
  };

  # Sound configuration
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };

  # Only change if mentioned in release notes.
  system.stateVersion = "20.09";
  system.autoUpgrade.enable = true;
}
