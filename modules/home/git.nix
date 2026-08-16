{ var, ... }:

{
  programs.git = {
    enable = true;

    ignores = [
      "*.bak"
      "*.swn"
      "*.swo"
      "*.swp"
      "*.un~"
      ".DS_Store"
    ];

    settings = {
      user.name = var.user.fullName;
      user.email = var.user.email;

      color.ui = "auto";
      help.autocorrect = 1;
      init.defaultBranch = "main";
      log.date = "iso";
      log.decorate = "full";
      merge.conflictStyle = "diff3";
      pull.rebase = true;
      push.default = "simple";

      alias = {
        am = "commit --amend";
        br = "branch --sort=-committerdate";
        cm = "commit -m";
        co = "checkout";
        cp = "cherry-pick";
        df = "diff";
        dfc = "diff --cached";
        fix = "commit --amend --no-edit";
        last = "log -1 HEAD --stat";
        lg = "log --graph --all --pretty=format:'%C(auto)%h%C(reset) - %C(auto)%d%C(reset) %s %C(green)(%cr)%C(reset) %C(bold blue)<%an>%C(reset)' --abbrev-commit";
        pff = "pull --ff-only";
        pfl = "push --force-with-lease origin HEAD";
        pl = "pull";
        ps = "push origin HEAD";
        rba = "rebase --abort";
        rbc = "rebase --continue";
        rbi = "rebase -i";
        recent = "log --oneline -20";
        root = "rev-parse --show-toplevel";
        st = "status";
        sta = "stash";
        std = "stash drop";
        stl = "stash list";
        stp = "stash pop";
        sw = "switch";
        swc = "switch -c";
        undo = "reset --soft HEAD~1";
        unstage = "restore --staged";
      };
    };
  };
}
