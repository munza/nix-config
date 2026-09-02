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

      # AnnotationMono ships no patched build, so Symbols Nerd Font Mono is fallback
      font-family = [
        "Annotation Mono"
        "Symbols Nerd Font Mono"
      ];
      font-size = 15;
      font-feature = "+calt,+liga,+dlig,+ss01,+ss02,+ss03,+ss04,+ss05";

      clipboard-read = "allow";
      clipboard-write = "allow";
    };
  };
}
