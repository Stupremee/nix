{
  home-manager.users.stu = { imports = [ ]; };

  users.users.stu = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
