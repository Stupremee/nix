{ pkgs, ... }: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemuRunAsRoot = false;
      allowedBridges = [ "virbr0" "virbr1" ];
    };

    containers.enable = true;
    oci-containers.backend = "docker";

    docker.enable = true;
  };

  # you'll need to add your user to 'libvirtd' group to use virt-manager
  environment.systemPackages = with pkgs; [ virt-manager ];
}
