{
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.plugin.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    # Nix operations live in the `nix-util` command (scripts/nix-util.sh), not in aliases.
    shellAliases = {
      nx = "nix-util";
      nxs = "nix-secret";
      ll = "ls -lah";
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    initContent = ''
      export MANPAGER="less -R --use-color -Dd+B -Du+G"

      autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search
      bindkey '^[[B' down-line-or-beginning-search

      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      setopt autopushd
      setopt pushdminus
      setopt pushdsilent
      setopt cdablevars

      setopt extended_glob
      setopt correct
    '';
  };

  # Shell history. Local-only: sync needs an explicit `atuin login`, and the
  # update check is off so no shell start-up reaches the network.
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # The arrow keys already do prefix search (bound below); let atuin own
    # Ctrl-R alone rather than taking over history navigation entirely.
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = false;
      update_check = false;
      style = "compact";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidget.command = "fd --type f --hidden --exclude .git";
    changeDirWidget.command = "fd --type d --hidden --exclude .git";
    # Atuin owns Ctrl-R; this is the supported way to yield it (Ctrl-T and
    # Alt-C stay with fzf).
    historyWidget.command = "";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
