{...}: {
  virtualisation.oci-containers.containers.mc-server = {
    image = "itzg/minecraft-server";

    environment = {
      EULA = "TRUE";
      MAX_MEMORY = "16G";
      MEMORY = "8G";
      ENABLE_ROLLING_LOGS = "true";
      USE_AIKAR_FLAGS = "true";
      VERSION = "1.20.4";
      TYPE = "FABRIC";
    };

    volumes = [
      "/var/lib/mc-server/data:/data"
      "/var/lib/mc-server/mods:/mods"
    ];

    ports = [
      "25565:25565"
      "24454:24454/udp"
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [25565];
    allowedUDPPorts = [24454];
  };
}
