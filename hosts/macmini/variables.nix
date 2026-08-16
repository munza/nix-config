{
  host.platform = "aarch64-darwin";

  # Path only — the key itself stays out of the repo.
  machine.sshPublicKeyFile = "~/.ssh/id_ed25519.pub";

  user = {
    name = "munza";
    fullName = "Tawsif Aqib";
    email = "hello@tawsifaqib.com";
  };

  # Pinned at install time; do not bump on upgrade.
  stateVersion = {
    system = 6;
    home = "26.05";
  };
}
