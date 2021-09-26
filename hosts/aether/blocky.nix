{ ... }: {
  services.blocky = {
    enable = false;

    options = {
      # Set default upstream DNS servers
      upstream.default = [
        "tcp-tls:1.1.1.1"
        "tcp-tls:1.0.0.1"
      ];
    };
  };
}
