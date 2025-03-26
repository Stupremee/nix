{ flake, ... }:
{
  imports = with flake.inputs; [
    self.nixosModules.default
    srvos.nixosModules.server

    ./disks.nix
  ];

  # Remote activation
  nixos-unified.sshTarget = "stu@rome";

  my = {
    persist = {
      enable = true;
      btrfs = {
        enable = true;
        disk = "/dev/disk/by-partlabel/disk-system-root";
      };
    };

    nix-common = {
      enable = true;
      maxJobs = 8;
      flakePath = "/home/stu/nix";
      isRemoteBuilder = true;
    };

    server.enable = true;

    secrets = {
      enable = true;
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEFO0TbdOgpnHFhsnHwi+VB/FMTGrTiXJtPcY+1lslT";
    };

    caddy.enable = true;
    paperless.enable = true;
    postfix.enable = true;
    oidc.enable = true;
    home-assistant.enable = true;
    stirling-pdf.enable = true;
  };

  # Required for allowing document scanner to connect via SSH
  users.users.paperless = {
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmfX3AdAEB8C/69EqEuvDFR9PfEHvsxweuUdMQ5JsVOvp4PCl2p+4xcMEclegQaYl8wXrf9s6DWPNzapeIzf7ZmigS6EVQlyz7sHgHT3t5dEW3jBvL2Hi/swgPb0h5YaN8odxq+/1HQfhwuW0Vor2kpU+jn7fRZ+2kiRJDqlbEBo0iP94lxvw5u/u0fUolkmbCB09hnoOQNrsgFpOuM1c1/DGshH/8EsB0rgRZm8gh+geh4f+c1CD3dXrtYuadMYacqX5D3KDrwrvOJwm7JC7BhOyBIZEyTmEOOi88mlLXAlXjpeTQTlHCx2lBBGNG3dOg2P7ceCKQoM82Lo77NUql root@BRW5CF370CD9392"
    ];
  };
  services.openssh.settings = {
    HostKeyAlgorithms = "ssh-rsa,ssh-rsa-cert-v01@openssh.com";
    PubkeyAcceptedAlgorithms = "+ssh-rsa,ssh-rsa-cert-v01@openssh.com";
    Macs = [
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
      "hmac-sha2-512"
    ];
  };

  networking = {
    hostName = "rome";
    hostId = "538d52a0";

    # Somehow, doesn't work. Need to figure out why
    enableIPv6 = false;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    enableAllFirmware = true;
  };

  # nixpkgs meta related options
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";
}
