{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.stirling-pdf;
in
{
  options.my.stirling-pdf = {
    enable = mkEnableOption "Enables Stirling PDF application";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."pdf.stu-dev.me".extraConfig = ''
      import cloudflare
      reverse_proxy :9827
    '';

    services.stirling-pdf = {
      enable = true;
      environment = {
        SERVER_HOST = "127.0.0.1";
        SERVER_PORT = "9827";
      };
    };
  };
}
