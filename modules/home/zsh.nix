{
  pkgs,
  var,
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

    shellAliases = {
      nix-rebuild = "sudo ${var.nix.builder} switch --flake '${var.paths.dotfiles}#${var.host.name}'";
      # Show what moved in flake.lock before trusting it: a rebuild runs input
      # code as root, so the lock diff is the supply-chain review surface.
      nix-update = "cd ${var.paths.dotfiles} && nix flake update && git diff --stat flake.lock && nix flake check --all-systems --no-build";
      nix-lock-diff = "git -C ${var.paths.dotfiles} diff flake.lock";
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
