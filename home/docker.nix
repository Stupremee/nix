{ ... }: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;

    autoPrune = {
      enable = true;
      dates = "10:00";
    };
  };
}
