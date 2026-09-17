# command-not-found and comma, backed by the prebuilt nix-index database.
#
# Typing a command that is not installed prints the packages providing it
# instead of a bare "command not found"; `, <cmd>` runs that command straight
# from nixpkgs in a throwaway shell. The database ships as a flake input, so
# neither needs the expensive local `nix-index` run.
{ inputs, ... }:

{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  programs.nix-index-database.comma.enable = true;
}
