# Enable the SSH daemon, allowing for connections via ssh.
{ ... }: {
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    forwardX11 = false;
  };
}
