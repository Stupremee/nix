{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.localsend;
in
{
  options.my.localsend = {
    enable = mkEnableOption "Install LocalSend and configure firewall.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      localsend
    ];

    networking.firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };
}
