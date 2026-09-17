{ pkgs, lib, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  # The Homebrew cask does not export this, and the shell integration needs it.
  home.sessionVariables = lib.mkIf isDarwin {
    GHOSTTY_RESOURCES_DIR = "/Applications/Ghostty.app/Contents/Resources/ghostty";
  };

  programs.ghostty = {
    enable = true;
    # macOS installs the app via Homebrew; elsewhere take it from nixpkgs.
    package = if isDarwin then null else pkgs.ghostty;
    enableZshIntegration = true;

    settings = {
      theme = "dark:Nightfox,light:Dayfox";

      # Send ⌥+key as Alt/Meta so terminal apps receive the modifier.
      macos-option-as-alt = true;

      # No tab bar, no title bar (window stays resizable from the edges).
      macos-titlebar-style = "hidden";

      # AnnotationMono ships no patched build, so Symbols Nerd Font Mono is fallback
      font-family = [
        "Comic Code Ligatures"
        "Symbols Nerd Font Mono"
      ];
      font-size = 15;
      font-feature = "+calt,+liga,+dlig,+ss01,+ss02,+ss03,+ss04,+ss05";

      clipboard-read = "allow";
      clipboard-write = "allow";
    };
  };
}
