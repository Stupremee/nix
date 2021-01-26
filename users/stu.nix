{ utils, ... }: {
  home-manager.users.stu = { imports = [ ]; };

  users.users.stu = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = utils.keysFromGithub {
      username = "Stupremee";
      sha256 = "";
    };
  };
}
