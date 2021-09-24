{ pkgs, nixos, deploy-rs, system, ... }:
pkgs.devshell.mkShell {
  name = "flk";
  imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];

  packages = with pkgs;
    [ git-crypt pre-commit binutils ];

  git.hooks = with pkgs; {
    enable = true;
    pre-commit.text = ''
      if ${git}/bin/git rev-parse --verify HEAD > /dev/null 2>&1
      then
        target=HEAD
      else
        # There is no commit in this repository yet,
        # so check against the empty tree.
        target="$(${git}/bin/git hash-object -t tree /dev/null)"
      fi

      exec 1>&2

      exec ${nixpkgs-fmt}/bin/nixpkgs-fmt \
          $(${git}/bin/git diff-index --name-only --cached $target \
          | ${ripgrep}/bin/rg '\.nix$' \
          | ${findutils}/bin/xargs -i sh -c 'test -f {} && echo {}')
    '';
  };

  commands = with pkgs; [
    {
      name = "nixpkgs-fmt";
      package = nixpkgs-fmt;
    }
    {
      name = "grip";
      package = python38Packages.grip;
    }
    {
      name = "git";
      package = git;
    }
    {
      name = "nix";
      package = nixUnstable;
    }
    {
      name = "deploy";
      package = deploy-rs.packages."${system}".deploy-rs;
    }
  ];
}
