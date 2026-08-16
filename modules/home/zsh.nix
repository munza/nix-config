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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
