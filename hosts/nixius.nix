# My main workstation PC.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/network/networkmanager.nix
  ];

  # Set 16 jobs
  nix.maxJobs = lib.mkDefault 16;

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
    initrd = {
      kernelModules = [ ];
      availableKernelModules =
        [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    };

    kernelModules = [ "usbmon" "v4l2loopback" "kvm-amd" ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = ''
      otpions v4l2loopback exclusive_caps=1 max_buffers=2
    '';

    tmpOnTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
  };

  # Configure xserver
  services.xserver = {
    videoDrivers = [ "nvidia" ];

    wacom.enable = true;

    modules = [ pkgs.xf86_input_wacom ];
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
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1a4a5671-32eb-4e43-8fd9-a1c2c64c8bf1";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7A23-1979";
    fsType = "vfat";
  };

  fileSystems."/mnt/hdd1" = {
    device = "/dev/disk/by-uuid/83d0d963-78af-4668-a4aa-824bffb44e12";
    fsType = "ext4";
  };

  fileSystems."/mnt/hdd2" = {
    device = "/dev/disk/by-uuid/f17408fb-5c6d-49ee-884f-fa6768b086a8";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

}
