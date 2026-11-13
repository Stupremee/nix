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
  url = "/local/technik-cards/technik-cards.js?v=${builtins.substring 11 8 "${cards}"}";
  resources = "${hass.configDir}/.storage/lovelace_resources";
  # Replace our entry, keep everything HACS and the UI registered.
  register = ''
    .data.items = ([.data.items[] | select(.url | startswith("/local/technik-cards/") | not)]
      + [{"id": "technikcards", "type": "module", "url": $url}])
  '';
in
lib.mkIf config.my.home-assistant.enable {
  systemd.tmpfiles.rules = [ "L+ ${hass.configDir}/www/technik-cards - - - - ${cards}" ];

  # A Lovelace resource, like HACS cards: dashboards wait for those before they
  # build cards. frontend.extra_module_url raced them and failed now and then.
  # customLovelaceModules would force Lovelace into YAML mode. HA is stopped
  # while preStart runs, so its storage file is safe to edit.
  systemd.services.home-assistant.preStart = lib.mkAfter ''
    if [ -f ${resources} ]; then
      ${lib.getExe pkgs.jq} --arg url '${url}' '${register}' ${resources} > ${resources}.tmp
      mv ${resources}.tmp ${resources}
    fi
  '';
}
