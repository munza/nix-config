{ pkgs, inputs }:

{
  homeModules = with inputs.self.homeModules; [
    aerospace
    clamav
    direnv
    ghostty
    git
    lazygit
    neovim
    secrets
    starship
    yazi
    zed
    zellij
    zsh
    zsh-functions
  ];

  systemPackages = with pkgs; [
    bat
    btop
    clamav
    curl
    devenv
    docker
    duf
    dust
    beamPackages.elixir_1_20
    fd
    gh
    gitleaks
    gping
    gum
    httpie
    jq
    kubectl
    llama-cpp
    lazydocker
    nixd
    nixfmt
    nmap
    nodejs
    openssl
    pkgconf
    procs
    python3
    ripgrep
    sops
    ssh-to-age
    trash-cli
    tree
    uv
  ];

  aiTools = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    opencode
  ];

  homebrew = {
    taps = [ ];
    brews = [
      "herdr"
    ];
    casks = [
      "appcleaner"
      "brave-browser"
      "bruno"
      "discord"
      "ghostty"
      "gitup-app"
      "google-chrome"
      "iina"
      "keka"
      "linear"
      "llama-app"
      "nordpass"
      "orbstack"
      "proton-drive"
      "proton-pass"
      "protonvpn"
      "raycast"
      "slack"
      "tolaria"
      "tailscale-app"
      "zed"
      "zen"
    ];
    masApps = { };
  };

  fonts = with pkgs; [
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.annotation-mono
    # Icon glyphs for fonts that ship no patched build, used as a fallback
    # family rather than baked into each font.
    nerd-fonts.symbols-only
  ];
}
