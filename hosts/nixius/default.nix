{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ../../hardware/nvidia.nix ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  users.users.stu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "docker" "disk" ];
    shell = pkgs.zsh;
  };

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
