{
  disko.devices = {
    disk = {
      vda = {
        imageSize = "8G";
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];

                postCreateHook = ''
                  MNTPOINT=$(mktemp -d)
                  mount -o subvol=/ "/dev/sda2" "$MNTPOINT"
                  trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
                  btrfs subvolume snapshot -r $MNTPOINT/rootfs $MNTPOINT/rootfs-blank
                '';

                subvolumes = {
                  "/rootfs" = {
                    mountOptions = ["compress=zstd"];
                    mountpoint = "/";
                  };

                  "/persist" = {
                    mountOptions = ["compress=zstd"];
                    mountpoint = "/persist";
                  };

                  "/nix" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/nix";
                  };

                  "/swap" = {
                    mountpoint = "/swap";
                    swap = {
                      swap1.size = "8G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
