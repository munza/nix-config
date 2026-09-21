# Herdr — terminal session manager. Installed via Homebrew (see
# hosts/macmini/host-packages.nix); not packaged in nixpkgs, so only the
# config file is managed here.
#
# herdr rewrites config.toml at runtime (onboarding flag, settings changed
# from its UI), so home-manager's read-only store symlink won't work — every
# write fails with "permission denied (os error 13)". Instead, the generated
# config is copied to a real, writable file. A hash stamp records the last
# deployed content: the file is only overwritten when the Nix-side settings
# actually change, so edits made from inside herdr survive otherwise (and are
# reset when the module's settings are updated and re-deployed).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.herdr;
  generatedConfig = (pkgs.formats.toml { }).generate "herdr-config.toml" cfg.settings;
in
{
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

  # Drop the read-only symlink; the activation script below installs a
  # writable copy instead.
  xdg.configFile."herdr/config.toml".enable = lib.mkForce false;

  home.activation.deployHerdrConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="${config.xdg.configHome}/herdr/config.toml"
    stamp="${config.xdg.stateHome}/herdr-config.deployed"

    desired=$(sha256sum ${generatedConfig} | cut -d' ' -f1)
    deployed=$(cat "$stamp" 2>/dev/null || true)

    if [ "$deployed" != "$desired" ] || [ -L "$target" ]; then
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "$(dirname "$stamp")" "$(dirname "$target")"
      # rm first: target may be the old read-only store symlink, which cp
      # would try to write through.
      $DRY_RUN_CMD rm -f $VERBOSE_ARG "$target"
      $DRY_RUN_CMD cp $VERBOSE_ARG ${generatedConfig} "$target"
      # Store files are mode 0444 and plain cp preserves that; herdr needs
      # the file writable.
      $DRY_RUN_CMD chmod $VERBOSE_ARG 0644 "$target"
      if [ -z "$DRY_RUN" ]; then
        printf '%s\n' "$desired" > "$stamp"
      fi
      # Tell a running server to pick the new file up, same as the
      # home-manager module's onChange would.
      if [ -z "$DRY_RUN" ] && command -v herdr >/dev/null 2>&1; then
        herdr server reload-config >/dev/null 2>&1 || true
      fi
    fi
  '';
}
