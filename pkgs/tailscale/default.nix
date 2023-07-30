{
  source,
  lib,
  stdenv,
  buildGo120Module,
  makeWrapper,
  iptables,
  iproute2,
  procps,
  shadow,
  getent,
}:
buildGo120Module rec {
  inherit (source) pname version src;
  vendorHash = "sha256-oELDIt+mRiBGAdoEUkSAs2SM6urkHm1aAtJnev8jDYM=";

  nativeBuildInputs = lib.optionals stdenv.isLinux [makeWrapper];

  CGO_ENABLED = 0;

  subPackages = ["cmd/tailscale" "cmd/tailscaled" "cmd/nginx-auth"];

  ldflags = [
    "-w"
    "-s"
    "-X tailscale.com/version.longStamp=${version}"
    "-X tailscale.com/version.shortStamp=${version}"
  ];

  doCheck = false;

  postInstall = lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/tailscaled --prefix PATH : ${lib.makeBinPath [iproute2 iptables getent shadow]}
    wrapProgram $out/bin/tailscale --suffix PATH : ${lib.makeBinPath [procps]}

    sed -i -e "s#/usr/sbin#$out/bin#" -e "/^EnvironmentFile/d" ./cmd/tailscaled/tailscaled.service
    install -D -m0444 -t $out/lib/systemd/system ./cmd/tailscaled/tailscaled.service

    mv $out/bin/nginx-auth $out/bin/tailscale-nginx-auth
  '';
}
