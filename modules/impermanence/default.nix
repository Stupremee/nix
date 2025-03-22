{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.persist;
in
{
  options.my.persist = {
    enable = mkEnableOption "Enable impermanence";

    directories = mkOption {
      type = types.listOf types.anything;
      default = [ ];
    };

    files = mkOption {
      type = types.listOf types.anything;
      default = [ ];
    };

    btrfs = {
      enable = mkEnableOption "Enable impermanence using btrfs rollbacks";

      disk = mkOption {
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.persistence."/persist" = {
        enable = true;
        hideMounts = true;

        directories = [
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
        ] ++ cfg.directories;

        files = [
          "/etc/machine-id"
        ] ++ cfg.files;
      };

      system.activationScripts."createPersistentStorageDirs".deps = [
        "var-lib-private-permissions"
        "users"
        "groups"
      ];
      system.activationScripts = {
        "var-lib-private-permissions" = {
          deps = [ "specialfs" ];
          text = ''
            mkdir -p /var/lib/private
            chmod 0700 /var/lib/private
          '';
        };
      };

      users.mutableUsers = false;
      my.user.root.enablePassword = true;

      services.openssh.hostKeys = [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];

      fileSystems."/persist".neededForBoot = true;
    }
    (mkIf cfg.btrfs.enable {
      boot.initrd.supportedFilesystems = [ "btrfs" ];

      boot.initrd.systemd.services.btrfs-rollback = {
        description = "Rollback btrfs root dataset to blank snapshot";
        wantedBy = [ "initrd.target" ];
        requires = [ "dev-disk-by\\x2dpartlabel-disk\\x2dsystem\\x2droot.device" ];
        after = [ "dev-disk-by\\x2dpartlabel-disk\\x2dsystem\\x2droot.device" ];
        before = [
          "-.mount"
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir /btrfs_tmp
          mount -t btrfs ${cfg.btrfs.disk} /btrfs_tmp
          if [[ -e /btrfs_tmp/rootfs ]]; then
              mkdir -p /btrfs_tmp/old_roots
              timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/rootfs)" "+%Y-%m-%-d_%H:%M:%S")
              mv /btrfs_tmp/rootfs "/btrfs_tmp/old_roots/$timestamp"
          fi

          delete_subvolume_recursively() {
              IFS=$'\n'
              for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                  delete_subvolume_recursively "/btrfs_tmp/$i"
              done
              btrfs subvolume delete "$1"
          }

          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
              delete_subvolume_recursively "$i"
          done

          btrfs subvolume create /btrfs_tmp/rootfs
          umount /btrfs_tmp
        '';
      };
    })
  ]);
}
