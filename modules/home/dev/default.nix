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
    k8s.enable = mkEnableOption "Enable global K8s tools for development";
  };

  config = mkMerge [
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
  ];
}
