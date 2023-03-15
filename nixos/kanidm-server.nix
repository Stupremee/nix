{config, ...}: let
  inherit (builtins) toString;

  port = 33005;

  secret = path: {
    file = path;
    owner = "kanidm";
    group = "kanidm";
    mode = "0440";
  };
in {
  age.secrets."cert/stu-dev.me.key" = secret ../secrets/cert/stu-dev.me.key;
  age.secrets."cert/stu-dev.me.pem" = secret ../secrets/cert/stu-dev.me.pem;

  modules.kanidm = {
    enableServer = true;
    enableClient = true;

    clientSettings = {
      uri = "https://127.0.0.1:${toString port}";
      verify_ca = false;
      verify_hostnames = false;
      ca_path = config.age.secrets."cert/stu-dev.me.pem".path;
    };

    serverSettings = {
      bindaddress = "127.0.0.1:${toString port}";

      tls_key = config.age.secrets."cert/stu-dev.me.key".path;
      tls_chain = config.age.secrets."cert/stu-dev.me.pem".path;

      domain = "auth.stu-dev.me";
      origin = "https://auth.stu-dev.me";
    };
  };

  modules.argo.route."auth.stu-dev.me" = {
    to = "https://127.0.0.1:${toString port}";
    tlsVerify = false;
  };
}
