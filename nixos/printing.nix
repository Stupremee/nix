{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      foomatic-db
    ];
  };
}
