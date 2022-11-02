{...}: {
  services.openssh = {
    enable = true;
    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
    forwardX11 = false;
    permitRootLogin = "prohibit-password";
  };
}
