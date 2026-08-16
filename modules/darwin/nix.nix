# Nix daemon settings shared by every darwin host.
# The NixOS equivalent belongs in modules/nixos/nix.nix (nix.gc uses `dates`
# there rather than `interval`).
_:

{
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
    interval.Weekday = 0;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
