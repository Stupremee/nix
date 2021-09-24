# Enable the SSH daemon, allowing for connections via ssh.
{ pkgs, ... }: {
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    forwardX11 = false;
  };

  users.users.root.openssh.authorizedKeys.keys = pkgs.lib.flk.myKeys pkgs;
}
