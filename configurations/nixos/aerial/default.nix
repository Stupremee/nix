{ flake, ... }:
{
  imports = with flake.inputs; [
    self.nixosModules.default
    srvos.nixosModules.server

    ./disks.nix
  ];

  # Remote activation
  nixos-unified.sshTarget = "stu@aerial";

  # Ryzen 7 7800X3D, ASRock B650I Lightning WiFi, Radeon RX 7900 XTX (24 GB).
  # Kernel modules, firmware and microcode come from this report. Regenerate with
  # `sudo nix run nixpkgs#nixos-facter -- -o facter.json` after hardware changes.
  hardware.facter.reportPath = ./facter.json;

  my = {
    persist = {
      enable = true;
      btrfs = {
        enable = true;
        disk = "/dev/mapper/cryptroot";
      };
      directories = [ "/var/lib/docker" ];
    };

    nix-common = {
      enable = true;
      maxJobs = 8;
    };

    nh = {
      enable = true;
      flakePath = "/home/stu/nix";
    };

    server.enable = true;
    agent-host.enable = true;
    secure-boot.enable = true;
    fonts.enable = true;
    user.stu.enableHome = true;

    amdgpu = {
      enable = true;
      compute.enable = true;
    };

    secrets = {
      enable = true;
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBC4ej9mMCt9V1IWlJH6pskTIN7LCsyEg5t7oekigVH";
    };
  };

  networking.hostName = "aerial";

  # Windows lives on the 2TB NVMe, but its boot manager sits on this ESP. systemd-boot lists
  # it automatically.
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
