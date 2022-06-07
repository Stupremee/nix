{ inputs, self, lib, ... }:
let
  inherit (inputs) deploy-rs;
in
{
  perSystem = { system, ... }: {
    checks = deploy-rs.lib."${system}".deployChecks self.deploy;
  };

  flake = {
    deploy = {
      magicRollback = true;
      autoRollback = true;

      nodes = builtins.mapAttrs
        (_: nixosConfig: {
          hostname =
            if builtins.isNull nixosConfig.config.modules.deploy.ip
            # Connection through Tailscale using MagicDNS
            then "${nixosConfig.config.networking.hostName}"
            else "${nixosConfig.config.modules.deploy.ip}";

          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib."${nixosConfig.pkgs.system}".activate.nixos nixosConfig;
          };
        })
        (lib.filterAttrs
          (_: v: v.config.modules.deploy.enable)
          self.nixosConfigurations);
    };
  };
}
