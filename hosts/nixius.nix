# My main workstation PC.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/network/networkmanager.nix
    ../profiles/network/ipfs.nix
    ../profiles/network/tailscale.nix
    ../profiles/sshd.nix

    ../profiles/zsa.nix
    ../profiles/yubikey.nix
    ../profiles/udiskie.nix
    ../profiles/virt.nix

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

  # Enable OpenVPN and add configurations to it
  age.secrets.tryHackMe.file = ../secrets/tryHackMe.ovpn;
  services.openvpn.servers = {
    tryHackMeVPN = {
      config = "config ${config.age.secrets.tryHackMe.path}";
      autoStart = false;
    };
  };

  # Use localtime to avoid time issues with windows dual boot
  time.hardwareClockInLocalTime = true;

  # Boot configuration
  boot = {
    tmpOnTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    initrd.kernelModules = [ ];

    kernelModules = [ "kvm-amd" "v4l2loopback" ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = ''
      otpions v4l2loopback exclusive_caps=1 max_buffers=2
    '';
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
