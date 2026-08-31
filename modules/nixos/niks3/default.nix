{
  config,
  lib,
  flake,
  ...
}:
with lib;
let
  cfg = config.my.niks3;
in
{
  imports = with flake.inputs; [
    niks3.nixosModules.niks3
  ];

  options.my.niks3 = {
    enable = mkEnableOption "Enable niks3 cache";
  };

  config = mkIf cfg.enable {
    age.secrets =
      let
        secret = path: {
          rekeyFile = path;
          owner = config.services.niks3.user;
          group = config.services.niks3.group;
        };
      in
      {
        r2-access-key = secret ../../../secrets/r2-access-key.age;
        r2-secret-key = secret ../../../secrets/r2-secret-key.age;
        niks3-api-token = secret ../../../secrets/niks3-api-token.age;
        niks3-sign-key = secret ../../../secrets/niks3-sign-key.age;
      };

    my.cloudflare-tunnel.enable = true;

    services.niks3 = {
      enable = true;
      httpAddr = "127.0.0.1:5751";

      s3 = {
        endpoint = "2c8c73b941397ffa0b50a8dd1fa274d1.eu.r2.cloudflarestorage.com";
        bucket = "nix-cache";
        useSSL = true;
        accessKeyFile = config.age.secrets.r2-access-key.path;
        secretKeyFile = config.age.secrets.r2-secret-key.path;
      };

      apiTokenFile = config.age.secrets.niks3-api-token.path;

      signKeyFiles = [
        config.age.secrets.niks3-sign-key.path
      ];

      # cacheUrl = "https://nix.stu-dev.me";

      oidc.providers = {
        github = {
          issuer = "https://token.actions.githubusercontent.com";
          audience = "https://nix.stu-dev.me";
          boundClaims = {
            repository_owner = [ "Deutsche-Warmepumpen-Werke" ];
          };
        };
      };
    };
  };
}
