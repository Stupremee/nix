{
  lib,
  pkgs,
  config,
  ...
}:
let
  cards = pkgs.callPackage ./package.nix { };
  hass = config.services.home-assistant;
  # The store hash in the URL makes browsers fetch each build fresh.
  version = builtins.substring 11 8 "${cards}";
in
lib.mkIf config.my.home-assistant.enable {
  # Served from www/ and loaded on every page, so storage-mode dashboards can
  # use the cards without the module's customLovelaceModules forcing YAML mode.
  systemd.tmpfiles.rules = [ "L+ ${hass.configDir}/www/technik-cards - - - - ${cards}" ];
  services.home-assistant.config.frontend.extra_module_url = [
    "/local/technik-cards/technik-cards.js?v=${version}"
  ];
}
