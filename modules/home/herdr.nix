# Herdr — terminal session manager. Installed via Homebrew (see
# hosts/macmini/host-packages.nix); not packaged in nixpkgs, so only the
# config file is managed here.
_: {
  programs.herdr = {
    enable = true;
    package = null;

    settings = {
      theme = {
        name = "tokyo-night";
        auto_switch = true;
        dark_name = "tokyo-night";
        light_name = "tokyo-night-day";
      };

      ui = {
        status_indicators = "symbols";
        show_agent_labels_on_pane_borders = true;
        toast.delivery = "terminal";
      };

      keys.command = [
        {
          key = [ "prefix+k" ];
          type = "plugin_action";
          command = "herdr-bar.open";
          description = "command bar";
        }
      ];
    };
  };
}
