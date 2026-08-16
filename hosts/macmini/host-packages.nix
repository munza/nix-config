{ pkgs, inputs }:

{
  homeModules = with inputs.self.homeModules; [
    aerospace
    clamav
    ghostty
    git
    lazygit
    neovim
    secrets
    starship
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
      "octarine"
      "orbstack"
      "proton-drive"
      "proton-pass"
      "protonvpn"
      "raycast"
      "slack"
      "tailscale-app"
      "zed"
      "zen"
    ];
    masApps = { };
  };

  fonts = with pkgs; [
    maple-mono.NF-unhinted
  ];
}
