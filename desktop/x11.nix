{ ... }: {

  services.xserver = {
    enable = true;
    xkbOptions = "caps:swapescape";
    layout = "eu";
  };
}
