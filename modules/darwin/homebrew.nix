{ hostPackages, ... }:

{
  config = {
    homebrew = {
      enable = true;

      onActivation.autoUpdate = false;
      onActivation.cleanup = "zap";
      onActivation.upgrade = true;
      global.autoUpdate = false;

      inherit (hostPackages.homebrew) taps;
      inherit (hostPackages.homebrew) brews;
      inherit (hostPackages.homebrew) casks;
      inherit (hostPackages.homebrew) masApps;
    };
  };
}
