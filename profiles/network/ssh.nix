{ ... }: {
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    forwardX11 = false;
    permitRootLogin = "prohibit-password";
    openFirewall = true;
  };
}
