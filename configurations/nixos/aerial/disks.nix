{
  disko.devices = {
    disk = {
      system = {
        imageSize = "8G";
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNU0WC12533N";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "500M";
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
                extraArgs = [ "-f" ];

                postCreateHook = ''
                  MNTPOINT=$(mktemp -d)
                  mount -o subvol=/ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNU0WC12533N-part2" "$MNTPOINT"
                  trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
                  btrfs subvolume snapshot -r $MNTPOINT/rootfs $MNTPOINT/rootfs-blank
                '';

                subvolumes = {
                  "/rootfs" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/";
                  };

                  "/home" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/home";
                  };

                  "/persist" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/persist";
                  };

                  "/nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/nix";
                  };

                  "/swap" = {
                    mountpoint = "/swap";
                    swap = {
                      swap1.size = "16G";
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
