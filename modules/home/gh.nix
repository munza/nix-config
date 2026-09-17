# gh — GitHub CLI, declaratively: settings and extensions rather than a bare
# package, so `gh dash` (a PR/issues TUI in the lazygit spirit) ships with it.
#
# NOTE: this manages ~/.config/gh/config.yml only; `gh auth login` state in
# hosts.yml is untouched.
{
  pkgs,
  ...
}:

{
  programs.gh = {
    enable = true;

    extensions = [ pkgs.gh-dash ];

    settings = {
      # Matches the SSH git operations protocol gh was authenticated with.
      git_protocol = "ssh";
      editor = "nvim";
      prompt = "enabled";
    };
  };
}
