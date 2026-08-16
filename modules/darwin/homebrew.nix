{ hostPackages, ... }:

{
  config = {
    homebrew = {
      enable = true;

      onActivation.autoUpdate = false;
      onActivation.cleanup = "uninstall";
      onActivation.upgrade = false;
      global.autoUpdate = false;

      inherit (hostPackages.homebrew) taps;
      inherit (hostPackages.homebrew) brews;
      inherit (hostPackages.homebrew) casks;
      inherit (hostPackages.homebrew) masApps;
    };
  };
}
