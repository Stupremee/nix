{
  config,
  lib,
  ...
}:
let
  cfg = config.my.avahi;
in
{
  options.my.avahi = with lib; {
    enable = mkEnableOption "Enable Avahi m-DNS discovery";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;

      openFirewall = true;
      nssmdns4 = true;
      ipv4 = true;
      ipv6 = true;

      publish.enable = false;
    };
  };
}
