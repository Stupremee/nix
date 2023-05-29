{...}: {
  services.openssh = {
    enable = true;

    settings = {
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
