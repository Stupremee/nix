# My main workstation PC.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/network/networkmanager.nix
    ../profiles/network/tailscale.nix

    ../profiles/zsa.nix
    ../profiles/yubikey.nix
    ../profiles/udiskie.nix

    ../profiles/graphical
    ../profiles/graphical/x11.nix
    ../profiles/graphical/bspwm.nix

    ../users/stu.nix
  ];

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set 16 jobs
  nix.maxJobs = lib.mkDefault 16;

  #modules.themes.theme = "HY";

  # Hardware configuaration
  hardware = {
    enableAllFirmware = false;
    cpu.amd.updateMicrocode = true;

    opengl = {
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
    };
  };
  services.fwupd.enable = true;

  # Boot configuration
  boot = {
    tmpOnTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  # Networking configuration
  networking.useDHCP = false;
  networking.interfaces.enp24s0.useDHCP = true;

  # Configure xserver
  services.xserver = {
    videoDrivers = [ "nvidia" ];

    wacom.enable = true;

    modules = [ pkgs.xf86_input_wacom ];
    displayManager.lightdm = {
      greeters.mini.enable = true;
      greeters.mini.user = "stu";
      greeters.mini.extraConfig = ''
        text-color = "#a3be8c"
        password-background-color = "#2e3440"
        window-color = "#4c566a"
        border-color = "#4c566a"
      '';
    };

    displayManager.setupCommands = ''
      ${pkgs.xlibs.xrandr}/bin/xrandr --output DP-1 --auto --left-of HDMI-0
    '';

    xrandrHeads = [
      {
        output = "HDMI-0";
        primary = true;
      }
      "DP-1"
    ];
  };

  # Filesystem configuration
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/34cf2e1e-cfe8-4529-a6e9-52ccb322a83c";
      fsType = "ext4";
    };

  fileSystems."/mnt/hdd1" =
    {
      device = "/dev/disk/by-uuid/83d0d963-78af-4668-a4aa-824bffb44e12";
      fsType = "ext4";
    };

  fileSystems."/mnt/hdd2" =
    {
      device = "/dev/disk/by-uuid/f17408fb-5c6d-49ee-884f-fa6768b086a8";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/A5FC-93D4";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/f2925a41-2fc0-40bd-9e60-38ad674a5b08"; }];
}
