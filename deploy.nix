{ deploy-rs, self, ... }: {
  aether = {
    hostname = "aether";

    profilesOrder = [ "system" ];
    profiles.system = {
      sshUser = "root";
      user = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.aether;
    };
  };
}
