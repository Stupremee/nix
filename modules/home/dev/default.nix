{
  lib,
  pkgs,
  pkgsUnstable,
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
        packages = with pkgsUnstable; [
          cloudflared
          mkcert
          attic-client
          nixd
          nixfmt
        ];

        sessionPath = [
          "$HOME/.kimi-code/bin"
          "$HOME/go/bin"
          "$HOME/.localcan/bin"
          "$HOME/.nub/shims"
          "$HOME/.nub/bin"
          "$HOME/.opencode/bin"
          "$HOME/.bun/bin"
          "$HOME/.cargo/bin"
          "$HOME/.local/bin"
          "/opt/homebrew/bin"
        ];
      };
    })

    (mkIf cfg.k8s.enable {
      home = {
        packages = with pkgsUnstable; [
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
          package = pkgsUnstable.k9s;
        };
        kubecolor = {
          enable = true;
          enableAlias = true;
          package = pkgsUnstable.kubecolor;
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
          packages = with pkgsUnstable; [
            (pkgs.azure-cli.withExtensions extensions)
            azure-functions-core-tools
          ];
        };
      }
    ))
  ];
}
