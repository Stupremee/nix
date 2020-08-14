{ lib, pkgs, rustPlatform
, stdenv, pkgconfig
, fetchFromGitHub, openssl
, libpulseaudio, dbus }:

rustPlatform.buildRustPackage rec {
  pname = "spotifyd";
  version = "0.2.24";

  src = fetchFromGitHub {
    owner = "Spotifyd";
    repo = "spotifyd";
    rev = "v${version}";
    sha256 = "08i0zm7kgprixqjpgaxk7xid1njgj6lmi896jf9fsjqzdzlblqk8";
  };

  cargoSha256 = "0kl8xl2qhzf8wb25ajw59frgym62lkg7p72d8z0xmkqjjcg2nyib";

  cargoBuildFlags = [
    "--no-default-features"
    "--features"
    "pulseaudio_backend,dbus_mpris"
  ];

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ openssl libpulseaudio dbus ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "An open source Spotify client running as a UNIX daemon";
    homepage = "https://github.com/Spotifyd/spotifyd";
    license = with licenses; [ gpl3 ];
    maintainers = with maintainers; [ anderslundstedt filalex77 marsam ];
    platforms = platforms.unix;
  };
}
