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

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Most of this flake's load (nixvim, home-manager, devenv projects) is
    # built by these two caches; without them unstable-tracking rebuilds
    # compile far more than they should. Read-only pulls, no push anywhere.
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];

    # Hard-link identical store paths on every write; complements the weekly
    # gc by shrinking what it has to hold.
    auto-optimise-store = true;
  };
}
