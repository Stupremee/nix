{config, ...}: {
  age.secrets.keycloakDatabase.file = ../secrets/password/keycloakDatabase;

  age.secrets."cert/stu-dev.me.key".file = ../secrets/cert/stu-dev.me.key;
  age.secrets."cert/stu-dev.me.pem".file = ../secrets/cert/stu-dev.me.pem;

  services.keycloak = {
    enable = true;
    settings = {
      hostname = "iron.stu-dev.me";
      hostname-strict-backchannel = true;
      http-port = 8181;
      https-port = 4343;
    };
    initialAdminPassword = "e6Wcm0RrtegMEHl"; # change on first login

    sslCertificateKey = config.age.secrets."cert/stu-dev.me.key".path;
    sslCertificate = config.age.secrets."cert/stu-dev.me.pem".path;

    database.type = "postgresql";
    database.passwordFile = config.age.secrets.keycloakDatabase.path;
    database.createLocally = true;
  };
}
