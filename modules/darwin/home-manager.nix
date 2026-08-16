# Blueprint already sets home-manager.users, useGlobalPkgs and useUserPackages
# from hosts/<host>/users/. Only the settings it does not cover live here.
{ pkgs, ... }:

{
  home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash-put";
}
