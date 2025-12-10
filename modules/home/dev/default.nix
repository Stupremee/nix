{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.my.dev;
in
{
  options.my.dev = {
    enable = mkEnableOption "Enable development tools";

    k8s.enable = mkEnableOption "Enable global K8s tools for development";

    azure.enable = mkEnableOption "Enable Azure CLI tools for development";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home = {
        packages = with pkgs.unstable; [
          claude-code
          cloudflared
        ];
      };
    })

    (mkIf cfg.k8s.enable {
      home = {
        packages = with pkgs.unstable; [
          kubectl
          kubelogin-oidc
          fluxcd
          kubectx
          kustomize
          kubernetes-helm
          stern
          kubent
        ];

        shellAliases = {
          k = "kubectl";
        };
      };

      programs = {
        k9s = {
          enable = true;
          package = pkgs.unstable.k9s;
        };
        kubecolor = {
          enable = true;
          enableAlias = true;
          package = pkgs.unstable.kubecolor;
        };
      };
    })

    (mkIf cfg.azure.enable (
      let
        extensions = with pkgs.azure-cli-extensions; [
          ad
          ssh
        ];
      in
      {
        home = {
          packages = with pkgs.unstable; [
            (pkgs.azure-cli.withExtensions extensions)
            azure-functions-core-tools
          ];
        };
      }
    ))
  ];
}
