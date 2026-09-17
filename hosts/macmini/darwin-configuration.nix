{
  flake,
  inputs,
  hostName,
  pkgs,
  ...
}:

let
  var = flake.lib.hostVars hostName;
  hostPackages = import ./host-packages.nix { inherit pkgs inputs; };
in
{
  # Blueprint discovers hosts/<host>/users/ and wires home-manager itself, so
  # only the darwin modules need these; users/munza.nix sets its own.
  _module.args = { inherit var hostPackages; };

  imports = [
    flake.darwinModules.home-manager
    flake.darwinModules.homebrew
    flake.darwinModules.nix
    flake.darwinModules.system
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nixpkgs.hostPlatform = var.host.platform;

  networking.hostName = var.host.name;

  users.users.${var.user.name}.home = var.user.homeDirectory;

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = var.user.name;
    mutableTaps = false;
  };

  environment.systemPackages = hostPackages.systemPackages ++ hostPackages.aiTools;

  fonts.packages = hostPackages.fonts;

  system.stateVersion = var.stateVersion.system;
}
