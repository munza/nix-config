{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./keymaps.nix
    ./plugins.nix
  ];

  programs.nixvim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      smartindent = true;
      wrap = false;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      signcolumn = "yes";
      updatetime = 250;
      scrolloff = 10;
      splitright = true;
      splitbelow = true;
    };

    colorschemes.nightfox = {
      enable = true;
      flavor = "terafox";
    };

    # Formatters and extra tools
    extraPackages = with pkgs; [
      # Go
      gotools
      gofumpt
      # Python
      black
      isort
      ruff
      # JS/TS
      oxfmt
      oxlint
      # Others
      stylua
      # mini.pick dependencies
      ripgrep
      fd
      # Debug adapters
      delve
      vscode-js-debug
      (python3.withPackages (ps: [ ps.debugpy ]))
      # AI assistance, driven from a toggleterm float
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    ];
  };
}
