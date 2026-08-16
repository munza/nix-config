# direnv — load a project's environment on cd
#
# nix-direnv swaps direnv's own nix integration for one that keeps the dev
# shell in the store and out of the garbage collector, so re-entering a
# project is instant rather than a rebuild.
#
# USAGE:
#   echo 'use flake' > .envrc && direnv allow
#   echo 'use devenv' > .envrc && direnv allow   # for devenv projects
_:

{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;

    # direnv narrates every load; only speak up on errors.
    config.global.hide_env_diff = true;
  };
}
