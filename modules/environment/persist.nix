{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.environment.persist;

  # ["/home/user/" "/.screenrc"] -> ["home" "user" ".screenrc"]
  splitPath = paths:
    (filter
      (s: builtins.typeOf s == "string" && s != "")
      (concatMap (builtins.split "/") paths)
    );

  # ["home" "user" ".screenrc"] -> "home/user/.screenrc"
  dirListToPath = dirList: (concatStringsSep "/" dirList);

  # ["/home/user/" "/.screenrc"] -> "/home/user/.screenrc"
  concatPaths = paths:
    let
      prefix = optionalString (hasPrefix "/" (head paths)) "/";
      path = dirListToPath (splitPath paths);
    in
    prefix + path;
in
{
  options.environment.persist = {
    erase = mkOption {
      type = types.bool;
      default = false;
      description = "Enable erasing of `/` at startup.";
    };

    files = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [
        "/etc/machine-id"
        "/etc/nix/id_rsa"
      ];
      description = ''
        Files in /etc that should be stored in persistent storage.
      '';
    };
  };

  config = mkIf cfg.erase {
    # Restore old state
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';

    environment.etc =
      let
        link = file:
          pkgs.runCommand
            "${replaceStrings [ "/" "." " " ] [ "-" "" "" ] file}"
            { }
            "ln -s '${file}' $out";

        # Create environment.etc link entry.
        mkLinkNameValuePair = file: {
          name = removePrefix "/etc/" file;
          value = { source = link (concatPaths [ "/persist" file ]); };
        };
      in
      listToAttrs (map mkLinkNameValuePair cfg.files);

    assertions =
      let
        files = concatMap (p: p.files or [ ]) (attrValues cfg);
      in
      [{
        # Assert that files are put in /etc, a current limitation,
        # since we're using environment.etc.
        assertion = all (hasPrefix "/etc") files;
        message =
          let
            offenders = filter (file: !(hasPrefix "/etc" file)) files;
          in
          ''
            environment.persist.files:
                Currently, only files in /etc are supported.
                Please fix or remove the following paths:
                  ${concatStringsSep "\n      " offenders}
          '';
      }];
  };
}
