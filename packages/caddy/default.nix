{ buildGoModule, lib, ... }:
buildGoModule {
  pname = "caddy";
  version = "v2.9.1-custom";
  src = ./src;
  runVend = true;

  vendorHash = "sha256-ZZI+Ns3hY/QYcvLNCqpxjEYHMNbhJIOt1ckHzMvqqYU=";
  # vendorHash = lib.fakeHash;

  meta = {
    homepage = "https://caddyserver.com";
    description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
    license = lib.licenses.asl20;
    mainProgram = "caddy";
    maintainers = with lib.maintainers; [
      Br1ght0ne
      emilylange
      techknowlogick
    ];
  };
}
