{
  flake,
  inputs,
  pkgs,
  ...
}:

let
  var = flake.lib.hostVars "macmini";
  hostPackages = import ../host-packages.nix { inherit pkgs inputs; };
in
{
  # Set here as well as by the host so that the standalone configuration
  # (`home-manager switch --flake .#munza@macmini`) resolves them too.
  _module.args = { inherit var hostPackages; };

  imports = hostPackages.homeModules;

  home.stateVersion = var.stateVersion.home;
}
