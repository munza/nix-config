_:

{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.deadnix.enable = true;
  programs.statix.enable = true;
  programs.shfmt.enable = true;
  programs.shellcheck.enable = true;

  settings.excludes = [
    ".direnv"
    "result"
  ];
}
