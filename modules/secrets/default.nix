{
  lib,
  pkgs,
  config,
  flake-self,
  ...
}:
with lib;
let
  cfg = config.my.secrets;

  dummyPubkey = "age1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqs3290gq";

in
{
  options.my.secrets = with lib; {
    enable = mkEnableOption "Enable secrets via agenix-rekey";
    sshKey = mkOption {
      type = with types; coercedTo path (x: if isPath x then readFile x else x) str;
      description = ''
        The age public key to use as a recipient when rekeying. This either has to be the
        path to an age public key file, or the public key itself in string form.
        HINT: If you want to use a path, make sure to use an actual nix path, so for example
        `./host.pub`, otherwise it will be interpreted as the content and cause errors.
        Alternatively you can use `readFile "/path/to/host.pub"` yourself.

        If you are managing a single host only, you can use `"/etc/ssh/ssh_host_ed25519_key.pub"`
        here to allow the rekey app to directly read your pubkey from your system.

        If you are managing multiple hosts, it's recommended to either store a copy of each
        host's pubkey in your flake and use refer to those here `./secrets/host1-pubkey.pub`,
        or directly set the host's pubkey here by specifying `"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."`.

        Make sure to NEVER use a private key here, as it will end up in the public nix store!
      '';
      default = dummyPubkey;
      example = literalExpression "./secrets/host1.pub";
    };
  };

  config = {
    age.rekey = {
      hostPubkey = cfg.sshKey;

      masterIdentities = [ ../../secrets/master-keys/yubikey-c.age ];
      storageMode = "local";
      generatedSecretsDir = flake-self.outPath + "/secrets/generated/${config.networking.hostName}";
      localStorageDir = flake-self.outPath + "/secrets/rekeyed/${config.networking.hostName}";
    };
  };
}
