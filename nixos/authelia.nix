{
  packages,
  pkgs,
  ...
}: let
  inherit (builtins) toString;

  port = 33003;

  usersFile = pkgs.writeText "users.yaml" ''
    users:
      authelia:
        disabled: false
        displayname: "Test User"
        password: "$argon2id$v=19$m=32768,t=1,p=8$eUhVT1dQa082YVk2VUhDMQ$E8QI4jHbUBt3EdsU1NFDu4Bq5jObKNx7nBKSn1EYQxk"  # Password is 'authelia'
        email: authelia@authelia.com
        groups:
          - admins
          - dev
  '';

  autheliaConfig = pkgs.writeText "authelia.yaml" ''
    theme: auto
    jwt_secret: sdlfjasdf

    default_redirection_url: https://google.com

    server:
      host: 0.0.0.0
      port: 9091
      path: ""
      read_buffer_size: 4096
      write_buffer_size: 4096
      enable_pprof: false
      enable_expvars: false
      disable_healthcheck: false
      tls:
        key: ""
        certificate: ""

    log:
      level: debug

    totp:
      issuer: stu-dev.me
      period: 30
      skew: 1

    authentication_backend:
      disable_reset_password: false
      refresh_interval: 5m
      file:
        path: ${usersFile}
        password:
          algorithm: argon2id
          iterations: 1
          key_length: 32
          salt_length: 16
          memory: 1024
          parallelism: 8

    access_control:
      default_policy: deny
      rules:
        - domain:
            - "auth.stu-dev.me"
          policy: bypass
        - domain: "docs.stu-dev.me"
          policy: one_factor

    session:
      name: authelia_session
      secret: foobar123
      expiration: 3600  # 1 hour
      inactivity: 300  # 5 minutes
      domain: stu-dev.me

    regulation:
      max_retries: 3
      find_time: 10m
      ban_time: 12h

    storage:
      local:
        path: /var/lib/authelia/db.sqlite3 #this is your databse. You could use a mysql database if you wanted, but we're going to use this one.
      encryption_key: you_must_generate_a_random_string_of_more_than_twenty_chars_and_configure_this

    notifier:
      disable_startup_check: true #true/false
      filesystem:
        filename: /var/lib/authelia/notif.txt
  '';
in {
  virtualisation.oci-containers.containers.authelia = {
    image = "authelia/authelia:4.37.5";

    ports = [
      "127.0.0.1:${toString port}:9091"
    ];
  };

  modules.argo.route."auth.stu-dev.me".toPort = port;
}
