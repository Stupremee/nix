{ config, ... }:
let
  cfg = config.services.vaultwarden;
in
{
  age.secrets.vaultwardenEnv = {
    file = ../../secrets/vaultwarden.ini;
    owner = "vaultwarden";
    group = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;

    environmentFile = config.age.secrets.vaultwardenEnv.path;
    config = {
      domain = "https://bw.stu-dev.me";
      signupsAllowed = false;

      rocketAddress = "127.0.0.1";
      rocketPort = 9000;
    };
  };
}
