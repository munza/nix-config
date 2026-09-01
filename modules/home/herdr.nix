# Herdr — terminal session manager. Installed via Homebrew (see
# hosts/macmini/host-packages.nix); not packaged in nixpkgs, so only the
# config file is managed here.
_: {
  programs.herdr = {
    enable = true;
    package = null;

    settings = {
      theme.auto_switch = true;

      keys.command = [
        {
          key = [
            "prefix+k"
            "ctrl+alt+k"
          ];
          type = "plugin_action";
          command = "herdr-bar.open";
          description = "command bar";
        }
      ];
    };
  };
}
