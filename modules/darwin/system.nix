{ var, ... }:

{
  config = {
    # Fingerprint unlock for sudo, where the attached keyboard has a reader;
    # harmless (plain password prompt) where it does not.
    security.pam.services.sudo_local.touchIdAuth = true;

    # Caps Lock is only ever pressed by accident; Vim and AeroSpace both want
    # one more Esc within reach instead.
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    system = {
      primaryUser = var.user.name;

      defaults = {
        dock = {
          autohide = true;
          mineffect = "scale";
          minimize-to-application = true;
          show-recents = false;
          wvous-bl-corner = 1;
          wvous-br-corner = 1;
          wvous-tl-corner = 1;
          wvous-tr-corner = 1;
          persistent-apps = [ ];
        };

        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "clmv";
          NewWindowTarget = "Home";
          QuitMenuItem = true;
          ShowExternalHardDrivesOnDesktop = false;
          ShowPathbar = true;
          ShowRemovableMediaOnDesktop = false;
          ShowStatusBar = true;
          _FXSortFoldersFirst = true;
          _FXSortFoldersFirstOnDesktop = false;
        };

        NSGlobalDomain = {
          AppleICUForce24HourTime = true;
          AppleInterfaceStyleSwitchesAutomatically = true;
          AppleMeasurementUnits = "Centimeters";
          AppleMetricUnits = 1;
          AppleScrollerPagingBehavior = true;
          AppleShowScrollBars = "Automatic";
          AppleTemperatureUnit = "Celsius";
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticInlinePredictionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
          NSDisableAutomaticTermination = false;
          NSTextShowsControlCharacters = true;
          "com.apple.keyboard.fnState" = false;
          "com.apple.mouse.tapBehavior" = 1;
          "com.apple.sound.beep.feedback" = 0;
          "com.apple.swipescrolldirection" = false;
        };

        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

        WindowManager = {
          AppWindowGroupingBehavior = false;
          EnableTiledWindowMargins = false;
        };

        loginwindow.GuestEnabled = false;

        screencapture.location = "~/Pictures/Screenshots";
      };

      startup.chime = false;
    };

    networking.applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      blockAllIncoming = false;
      allowSigned = true;
      allowSignedApp = false;
    };
  };
}
