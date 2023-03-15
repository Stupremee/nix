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
  age.secrets."cert/localhost.key" = secret ../secrets/cert/localhost.key;
  age.secrets."cert/localhost.pem" = secret ../secrets/cert/localhost.pem;

  security.pki.certificates = [
    ''
      localhost
      =========
      -----BEGIN CERTIFICATE-----
      MIIEXDCCAsSgAwIBAgIRAMmyamm0T1AeXXnc77++j8swDQYJKoZIhvcNAQELBQAw
      gYMxHjAcBgNVBAoTFW1rY2VydCBkZXZlbG9wbWVudCBDQTEsMCoGA1UECwwjc3R1
      QFN0dXMtTWFjQm9vay0zLmxvY2FsIChKdXN0dXMgSykxMzAxBgNVBAMMKm1rY2Vy
      dCBzdHVAU3R1cy1NYWNCb29rLTMubG9jYWwgKEp1c3R1cyBLKTAeFw0yMzAzMTUx
      MjA4MDVaFw0yNTA2MTUxMTA4MDVaMFcxJzAlBgNVBAoTHm1rY2VydCBkZXZlbG9w
      bWVudCBjZXJ0aWZpY2F0ZTEsMCoGA1UECwwjc3R1QFN0dXMtTWFjQm9vay0zLmxv
      Y2FsIChKdXN0dXMgSykwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDH
      dVwYSYRAZfnaamj6Jn5Q1BYxh7S7SRwtUjZ7vRGRjd+00LaH2RvAoFujQsO3YYQ0
      lowlQE190NYRogg8DR7Cq3goTnnYp9TMg/PtE+MmWEr/Avnwzp07a4Vd34h6NEfk
      xolJg4ZDRn9fdaR+Esg2onjZh1L6ye9WpuKcboL7U7yHVNFdEK93JftjledHyZ9S
      tQvv0pA7nP6/KdwUopDOwkU341Rg7ubXyf/KZYolagKu9f0NlygCPrr+Eopr/OI9
      3xS5oEm4mQpSe61QcL6Do2v+BgspgXOXKftzMXuTg/uAiWEMp58zT2GK+FOmcUPV
      meE+VHTGCw5ZfGMqS/tLAgMBAAGjdjB0MA4GA1UdDwEB/wQEAwIFoDATBgNVHSUE
      DDAKBggrBgEFBQcDATAfBgNVHSMEGDAWgBSbUFmJdpqphy7YRb1zrvGH26rMpDAs
      BgNVHREEJTAjgglsb2NhbGhvc3SHBH8AAAGHEAAAAAAAAAAAAAAAAAAAAAEwDQYJ
      KoZIhvcNAQELBQADggGBADaVeDcJmw7Vksl5O3ev816w8d6DqXxMNJA09P7Kyvse
      yczerAPqh5rZjDRffqgN4Oh8FyXZRcGpZpCkncxDQqwv4boyto6LCuGNAMEEqLP4
      Yyagi99SCB1W/x8UjAJQFD/jYLVfIPxur2w59CO5pedrfFUG3+TqJPj+oTkMjgqG
      0zVlBrMFCttM41z6+03T85h8yDzcSKQoJGMu8HJK2nz9RA+tgi0QStuGWKOiSWAs
      nHfHxz/qPA5KimvPBUkc65FUub14IV7XrGDtA2V/X4lV5B0qvGHDkhCvBMS1NXVr
      ld9wdD5v4fOxAVWGFIX1JBiEEtGnO5vCw2Fyf8bzusEkkmnxtWOaHVN/DtxVs/p6
      hSUnCJKMJBdlYLo74CNmrK7Opgyt61I2+a1VxbAnD0NQL/9JFcxDWBxwW59ixdEe
      4hu1E37PQz1XAHxhpyjGjwCJAeVcWO5lP5mcBMwwGM3mluqKKzY48QcD7z6eg1J8
      3F5L+YbNqFnlXoy1ATl7Xg==
      -----END CERTIFICATE-----
    ''
  ];

  modules.kanidm = {
    enableServer = true;
    enableClient = true;

    clientSettings = {
      uri = "https://127.0.0.1:${toString port}";
      verify_ca = false;
      verify_hostnames = false;
      ca_path = config.age.secrets."cert/localhost.pem".path;
    };

    serverSettings = {
      bindaddress = "127.0.0.1:${toString port}";

      tls_key = config.age.secrets."cert/localhost.key".path;
      tls_chain = config.age.secrets."cert/localhost.pem".path;

      domain = "auth.stu-dev.me";
      origin = "https://auth.stu-dev.me";
    };
  };

  modules.argo.route."auth.stu-dev.me".to = "https://127.0.0.1:${toString port}";
}
