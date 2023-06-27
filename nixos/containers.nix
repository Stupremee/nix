{pkgs, ...}: {
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "docker";

    docker = {
      enable = true;
      rootless.enable = true;
      autoPrune = {
        enable = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [docker-compose];

  systemd.services."docker-binfmt-setup" = {
    wantedBy = ["multi-user.target"];

    script = "${pkgs.docker}/bin/docker run --rm --privileged multiarch/qemu-user-static --reset -p yes";

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
