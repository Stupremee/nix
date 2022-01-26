# Enable the SSH daemon, allowing for connections via ssh.
{ pkgs, ... }: {
  services.openssh = {
    enable = true;
    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
    forwardX11 = false;
    permitRootLogin = "prohibit-password";
  };

  users.users.root.openssh.authorizedKeys.keys = pkgs.lib.flk.myKeys pkgs;
}
