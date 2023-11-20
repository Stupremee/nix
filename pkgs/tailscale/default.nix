{
  source,
  lib,
  stdenv,
  unstable,
  makeWrapper,
  iptables,
  iproute2,
  procps,
  shadow,
  getent,
}:
unstable.buildGo121Module rec {
  inherit (source) pname version src;
  vendorHash = "sha256-/kuu7DKPklMZOvYqJpsOp3TeDG9KDEET4U0G+sq+4qY=";

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
