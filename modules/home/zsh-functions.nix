# Zsh custom functions
#
# USAGE:
#   Add a new function by creating a .sh file in the scripts/ directory.
#   Each function is sourced automatically on shell init.
#
# TO ADD A NEW FUNCTION:
#   1. Create scripts/<name>.sh with a shell function
#   2. Add a source line below
#   3. Rebuild: nix-rebuild
#
{ var, ... }:

let
  dotfiles = builtins.replaceStrings [ "~" ] [ var.user.homeDirectory ] var.paths.dotfiles;
in
{
  programs.zsh.initContent = ''
    export DOTFILES="${dotfiles}"
    source ${../../scripts/nix-secret.sh}
  '';
}
