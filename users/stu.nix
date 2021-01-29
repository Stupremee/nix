{ pkgs, lib, ... }:
let utils = import ../lib/utils.nix { inherit lib; };
in {
  home-manager.users.stu = { imports = [ ./profiles/graphical/sway ]; };

  users.users.stu = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = utils.keysFromGithub {
      inherit pkgs;
      username = "Stupremee";
      sha256 = "sha256-QXJfmJjokI1rTHD7xK5Q+vQ6IeWZ9SrjM7uTnMoe/Iw=";
    };
  };
}
