{ pkgs, inputs }:

{
  homeModules = with inputs.self.homeModules; [
    aerospace
    clamav
    direnv
    ghostty
    git
    herdr
    lazygit
    nixvim
    secrets
    starship
    yazi
    zed
    zsh
    zsh-functions
  ];

  systemPackages = with pkgs; [
    # Essentials & utilities
    btop
    curl
    httpie
    gh
    gitleaks
    gping
    gum
    jq

    # Containers & orchestration
    docker
    kubectl
    lazydocker

    # Environment & native build deps
    devenv
    openssl
    pkgconf

    # File & system replacements
    bat # cat
    fd # find
    ripgrep # grep
    tree
    dust # du
    duf # df
    procs # ps
    trash-cli # rm

    # Elixir
    beamPackages.elixir_1_20

    # Go
    go
    golangci-lint
    gopls
    gotools
    delve

    # Nix
    nixd
    nixfmt

    # Python
    python3
    uv

    # Rust
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
    cargo-watch

    # JavaScript
    nodejs

    # Security
    clamav
    nmap
    sops
    ssh-to-age

    # Local AI
    llama-cpp
  ];

  aiTools = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    pi
  ];

  homebrew = {
    taps = [ ];
    brews = [
      "herdr"
    ];
    casks = [
      "appcleaner"
      "bruno"
      "claude"
      "discord"
      "firefox"
      "ghostty"
      "iina"
      "keka"
      "linear"
      "llama-app"
      "opensuperwhisper"
      "orbstack"
      "proton-drive"
      "proton-pass"
      "protonvpn"
      "raycast"
      "slack"
      "tailscale-app"
      "zed"
    ];
    masApps = { };
  };

  fonts = with pkgs; [
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.annotation-mono
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.comic-code
    # Icon glyphs for fonts that ship no patched build, used as a fallback
    # family rather than baked into each font.
    nerd-fonts.symbols-only
  ];
}
