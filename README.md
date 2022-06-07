# NixOS configuration

## Installation

### Install on Hetzner Cloud

```bash
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

# Dataset for `/boot`
zfs create -p -o mountpoint=legacy rpool/local/boot
mkdir /mnt/boot
mount -t zfs rpool/local/boot /mnt/boot

# Dataset for `/home`
zfs create -p -o mountpoint=legacy rpool/safe/home
mkdir /mnt/home
mount -t zfs rpool/safe/home /mnt/home

# Dataset for persistent state
zfs create -p -o mountpoint=legacy rpool/safe/persist
mkdir /mnt/persist
mount -t zfs rpool/safe/persist /mnt/persist


# Important, otherwise `sshd` wont be able to start on first boot
mkdir -p /mnt/persist/etc/ssh
```
