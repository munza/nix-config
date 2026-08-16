# ClamAV on-demand scanning. Only enable this on hosts that also install the
# clamav package in host-packages.nix.
{ var, ... }:

{
  xdg.configFile."clamav/freshclam.conf".text = ''
    DatabaseDirectory ${var.user.homeDirectory}/.local/share/clamav
    DatabaseMirror database.clamav.net
  '';

  programs.zsh.shellAliases = {
    clam-update = ''mkdir -p "$HOME/.local/share/clamav" && freshclam --config-file="$HOME/.config/clamav/freshclam.conf"'';
    clam-scan = ''clamscan --database="$HOME/.local/share/clamav" --recursive --infected --bell --fail-if-cvd-older-than=7'';
  };
}
