#! /usr/bin/env bash

# Script to install NixOS from the Hetzner Cloud NixOS bootable ISO image.
#
# curl -L https://raw.githubusercontent.com/Stupremee/nix/master/hosts/install-hetzner-cloud.sh | sudo bash

set -e

# Hetzner Cloud OS images grow the root partition to the size of the local
# disk on first boot. In case the NixOS live ISO is booted immediately on
# first powerup, that does not happen. Thus we need to grow the partition
# by deleting and re-creating it.
sgdisk -d 1 /dev/sda
sgdisk -N 1 /dev/sda
partprobe /dev/sda

# Setup ZFS pools and datasets
zpool destroy -f rpool || true
zpool create -f rpool /dev/sda1

# Dataset for `/`
zfs create -p -o mountpoint=legacy rpool/local/root
zfs snapshot rpool/local/root@blank
mount -t zfs rpool/local/root /mnt

# Dataset for `/nix`
zfs create -p -o mountpoint=legacy rpool/local/nix
mkdir /mnt/nix
mount -t zfs rpool/local/nix /mnt/nix

# Dataset for `/home`
zfs create -p -o mountpoint=legacy rpool/safe/home
mkdir /mnt/home
mount -t zfs rpool/safe/home /mnt/home

# Dataset for persistent state
zfs create -p -o mountpoint=legacy rpool/safe/persist
mkdir /mnt/persist
mount -t zfs rpool/safe/persist /mnt/persist

nixos-generate-config --root /mnt

# Delete trailing `}` from `configuration.nix` so that we can append more to it.
sed -i -E 's:^\}\s*$::g' /mnt/etc/nixos/configuration.nix

# Extend/override default `configuration.nix`:
echo '
  boot.loader.grub.devices = [ "/dev/sda" ];
  boot.initrd.postDeviceCommands = pkgs.lib.mkAfter '"''
    zfs rollback -r rpool/local/root@blank
  ''"';

  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC25o7zyW1Jg3cIJau638oTdGcGM1pFalyGN27++nWhYQeeeE41MhbqBT05UMmkZkdKBfhpBOdQkbcki4ASlnFOLt1Bk67dWD6s0m0sslGtBIq9qLqoC81n1c3juQrF0UDg4Ww7oZ/7Ba6uWkVWOyAbiRYjjbKI/0ml/HYKVETj5XKxe8FBkC53MWh3b/tpMs/gvvAGSFwTexIeQXTz+sOvhASmNgIKntWa2eKd8sszOCYfl82dTZAx0eYsYgaL9p5mLH6XK/8KuIuDs5Rgz4P9APvO1o4HgEn3OrBQwZFog/aVDeOl0umDEw8+hbnEt7A7iaNXLnY9sQtRh+eq9HPaaJavtVI4AoqOJ30XzlQP5eCQUaFQ3RbqDVp1JAarh9SYvWeKPCSzFDHcYDBKp7x8hXcZl8inwwmExgJneryOXkUkmX9+FK7NruYNhVif3lcxlvHbx940olVk7gkBmwHmCrH4KVWWZ+UYS/m1rW6m/f9tKZigcuTBo+Pld3ZPLJQWZyJUi0xoKudo+cNpnDzZYSxEHjvaX7lxLEWNnYYh772A6vJRXw5hg8AuDsH+w9AyM7d/ZtIFVe232maAXl2qgBJZghBEs7VHje5908mXaXI4qgsa6itG3EqXHlWQ/tPxvDr/rAsBJnVtY2GMobnbj3vCFL0AmXjV04+pcmMBBw== openpgp:0x45DDDA9E"
  ];
}
' >> /mnt/etc/nixos/configuration.nix

nixos-install --no-root-passwd

poweroff
