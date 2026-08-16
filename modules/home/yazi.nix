# yazi — terminal file manager
#
# USAGE:
#   yazi           — browse from here
#   y              — browse, and cd the shell to wherever you quit
#
# The `y` wrapper is what makes it useful as a navigation tool rather than
# just a viewer; plain `yazi` cannot change its parent shell's directory.
_:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    settings.mgr = {
      show_hidden = true;
      sort_dir_first = true;
    };
  };
}
