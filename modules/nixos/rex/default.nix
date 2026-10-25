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
  };

  config = mkIf cfg.enable {
    # Serve gives the Mac app the HTTPS it requires on https://<host>.<tailnet>.ts.net:7297.
    # It forwards no identity for tagged devices, so only user-owned nodes get in.
    services.rex.loginServer = {
      enable = true;
      tailscaleServe.enable = true;
      accounts.${config.my.user.mainUser}.principals = cfg.principals;
    };

    # Holds the pkgs.superlogical.com pre-release token, needed to fetch the rex input.
    my.persist.files = [ "/etc/nix/netrc" ];
  };
}
