{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.rex;
in
{
  options.my.rex = {
    enable = mkEnableOption "Enable the Rex login server";

    principals = mkOption {
      type = types.listOf types.str;
      default = [ "tailscale:Stupremee@github" ];
      description = "Principals allowed to log in as the main user";
    };

    tailnetListen = mkOption {
      type = types.str;
      default = "tailnet://:7298";
      description = "tailnet:// listener for tagged callers. An empty IP binds every tailnet address, IPv6 included";
    };
  };

  config = mkIf cfg.enable {
    # Serve gives the Mac app the HTTPS it requires on https://<host>.<tailnet>.ts.net:7297.
    # It forwards no identity for tagged devices, so those use the plain-HTTP
    # tailnet:// listener on 7298 instead. Serve owns 7297 for all tailnet traffic.
    services.rex.loginServer = {
      enable = true;
      tailscaleServe.enable = true;
      extraListen = [ cfg.tailnetListen ];
      accounts.${config.my.user.mainUser}.principals = cfg.principals;
    };

    # Holds the pkgs.superlogical.com pre-release token, needed to fetch the rex input.
    my.persist.files = [ "/etc/nix/netrc" ];
  };
}
