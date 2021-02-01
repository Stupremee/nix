{ pkgs, ... }:
pkgs.devshell.mkShell { }

# { pkgs, nixos, ... }:
# pkgs.devshell.mkShell rec {
#name = "flk";

#packages = with pkgs; [ git-crypt pre-commit ];

#git.hooks = with pkgs; {
#enable = true;
#pre-commit.text = ''
#exec ${./pre-commit.sh}
#'';
#};

#commands = with pkgs;
#(let grip = python38Packages.grip;
#in [
#{
#name = nixpkgs-fmt.pname;
#package = nixpkgs-fmt;
#help = nixpkgs-fmt.meta.description;
#}
#{
#name = grip.pname;
#package = grip;
#help = grip.meta.description;
#}
#{
#name = git.pname;
#package = git;
#help = git.meta.description;
#}
#{
#name = "nix";
#package = nixUnstable;
#help = nixUnstable.meta.description;
#}
#]);
#}
