{
  disko.devices = {
    disk = {
      system = {
        imageSize = "8G";
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4CNNX0N802751K";
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
                  mount -o subvol=/ "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4CNNX0N802751K-part2" "$MNTPOINT"
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

      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_DT01ACA100_2615J0UNS";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };

      hdd2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_HDWD110_Z8LJUY3FS";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";
        mode = "";

        # Workaround: cannot import 'zroot': I/O error in disko tests
        options.cachefile = "none";

        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          data = {
            type = "zfs_fs";
            mountpoint = "/data";
          };
        };
      };
    };
  };
}
