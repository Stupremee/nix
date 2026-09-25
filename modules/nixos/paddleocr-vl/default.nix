{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.paddleocr-vl;

  stateDirectory = "/var/lib/paddleocr-vl";
  image = "ghcr.io/stupremee/paddleocr-vl:main";
  docker = "${config.virtualisation.docker.package}/bin/docker";
in
{
  options.my.paddleocr-vl = {
    enable = mkEnableOption "PaddleOCR-VL OCR service (VLM inference on Runpod)";

    port = mkOption {
      type = types.port;
      default = 8330;
      description = "Host loopback port for the OCR API";
    };

    backend = mkOption {
      type = types.enum [
        "runpod"
        "emulated"
      ];
      default = "runpod";
      description = "`emulated` answers with canned VLM output and needs no GPU or Runpod credentials";
    };

    workerConcurrency = mkOption {
      type = types.ints.positive;
      default = 4;
      description = "Jobs processed at once; each needs roughly 1-2 GB RAM";
    };

    autoUpdate = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Periodically pull the :main image and restart the container when it changed";
      };
      onCalendar = mkOption {
        type = types.str;
        default = "*:0/15";
        description = "systemd OnCalendar expression for the update check";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      my = {
        docker.enable = true;
        # The job queue must survive reboots. It only holds short-lived job
        # data, so it is not backed up.
        persist.directories = [
          {
            directory = stateDirectory;
            mode = "0700";
          }
        ];
      };

      systemd.tmpfiles.rules = [ "d ${stateDirectory} 0700 root root -" ];

      virtualisation.oci-containers.containers.paddleocr-vl = {
        inherit image;
        ports = [ "127.0.0.1:${toString cfg.port}:8080" ];
        environment = {
          OCR_BACKEND = cfg.backend;
          WORKER_CONCURRENCY = toString cfg.workerConcurrency;
        };
        volumes = [ "${stateDirectory}:/data" ];
      };

      # Pull :main and restart only when the image actually changed. Jobs that
      # are running during a restart are requeued by the service on startup.
      systemd.services.paddleocr-vl-update = mkIf cfg.autoUpdate.enable {
        description = "Update the paddleocr-vl container image";
        after = [
          "network-online.target"
          "docker.service"
        ];
        wants = [ "network-online.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          before="$(${docker} image inspect --format '{{.Id}}' ${image} 2>/dev/null || true)"
          ${docker} pull --quiet ${image}
          after="$(${docker} image inspect --format '{{.Id}}' ${image})"
          if [ "$before" != "$after" ]; then
            echo "new image $after, restarting paddleocr-vl"
            systemctl restart docker-paddleocr-vl.service
          fi
        '';
      };

      systemd.timers.paddleocr-vl-update = mkIf cfg.autoUpdate.enable {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.autoUpdate.onCalendar;
          RandomizedDelaySec = "2m";
          Persistent = true;
        };
      };
    }

    # Emulated mode needs no credentials, so the secret is only required for Runpod.
    (mkIf (cfg.backend == "runpod") {
      age.secrets.paddleocr-vl-env.rekeyFile = ../../../secrets/paddleocr-vl.env.age;

      virtualisation.oci-containers.containers.paddleocr-vl.environmentFiles = [
        config.age.secrets.paddleocr-vl-env.path
      ];
    })
  ]);
}
