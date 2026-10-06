{
  # The 2TB NVMe (Samsung 980 PRO S736NU0WC13048Z) holds Windows with BitLocker and is
  # deliberately not managed here.
  disko.devices.disk.system = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNU0WC12533N";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            # Only read at install time (nixos-anywhere --disk-encryption-keys). At boot the
            # volume unlocks via the TPM2 token, with the passphrase as fallback.
            passwordFile = "/tmp/disk.key";
            settings = {
              allowDiscards = true;
              crypttabExtraOpts = [ "tpm2-device=auto" ];
            };

            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];

              subvolumes = {
                # Recreated empty on every boot by my.persist.btrfs
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
                  swap.swapfile.size = "16G";
                };
              };
            };
          };
        };
      };
    };
  };
}
