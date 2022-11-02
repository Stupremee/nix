{
  config,
  pkgs,
  ...
}: {
  virtualisation = {
    containers.enable = true;
    containers.storage.settings.storage = {
      driver = "zfs";
      graphroot =
        if config.modules.eraseDarlings.enable
        then "/persist/var/lib/containers/storage"
        else "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };

    oci-containers.backend = "podman";

    podman = {
      enable = true;
      extraPackages = [pkgs.zfs];
    };
  };
}
