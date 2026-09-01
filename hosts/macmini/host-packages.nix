{ pkgs, inputs }:

{
  homeModules = with inputs.self.homeModules; [
    aerospace
    clamav
    direnv
    ghostty
    git
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
    # Icon glyphs for fonts that ship no patched build, used as a fallback
    # family rather than baked into each font.
    nerd-fonts.symbols-only
  ];
}
