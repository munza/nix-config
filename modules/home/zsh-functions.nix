# Zsh custom functions
#
# USAGE:
#   Add a new function by creating a .sh file in the scripts/ directory.
#   Each function is sourced automatically on shell init.
#
# TO ADD A NEW FUNCTION:
#   1. Create scripts/<name>.sh with a shell function
#   2. Add a source line below
#   3. Rebuild: nix-util rebuild
#
{ var, ... }:

let
  configDir = builtins.replaceStrings [ "~" ] [ var.user.homeDirectory ] var.paths.config;
in
{
  programs.zsh.initContent = ''
    # Exported: also meant to be typed (cd $FLAKE_DIR), and the scripts fail
    # without it. The other two are read only by nix-util, so they stay shell-local
    # rather than riding along in every child process.
    export FLAKE_DIR="${configDir}"
    NIX_BUILDER="${var.nix.builder}"
    NIX_HOST="${var.host.name}"
    source ${../../scripts/nix-secret.sh}
    source ${../../scripts/nix-util.sh}
  '';
}
