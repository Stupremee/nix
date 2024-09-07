{config, ...}: {
  age.secrets.curseforgeEnv.file = ../secrets/curseforge.env;

  virtualisation.oci-containers.containers.atm9-server = {
    image = "itzg/minecraft-server";

    environment = {
      EULA = "TRUE";
      MAX_MEMORY = "32G";
      MEMORY = "16G";
      ENABLE_ROLLING_LOGS = "true";
      USE_AIKAR_FLAGS = "true";
      VERSION = "1.20.1";
      TYPE = "AUTO_CURSEFORGE";
      CF_SLUG = "all-the-mods-9";
      MOTD = "PC Bauen";
      ENABLE_WHITELIST = "TRUE";
      ICON = "/data/icon.png";
    };

    environmentFiles = [config.age.secrets.curseforgeEnv.path];

    volumes = [
      "/var/lib/atm9-server/data:/data"
      "/var/lib/atm9-server/mods:/mods"
      "/var/lib/atm9-server/downloads:/downloads"
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
