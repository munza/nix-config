{ pkgs, ... }:

{
  programs.nixvim.plugins = {

    # ── mini.nvim ──
    mini = {
      enable = true;
      mockDevIcons = true;
      modules = {
        icons = { };
        statusline = { };
        tabline = { };
        files = { };
        pick = { };
        extra = { };
        clue = {
          window = {
            delay = 0;
            config = {
              width = "auto";
            };
          };
          triggers = [
            {
              mode = "n";
              keys = "<Leader>";
            }
            {
              mode = "x";
              keys = "<Leader>";
            }
            {
              mode = "n";
              keys = "g";
            }
            {
              mode = "x";
              keys = "g";
            }
            {
              mode = "n";
              keys = "z";
            }
            {
              mode = "x";
              keys = "z";
            }
            {
              mode = "n";
              keys = "'";
            }
            {
              mode = "n";
              keys = "\"";
            }
            {
              mode = "n";
              keys = "<C-w>";
            }
            {
              mode = "i";
              keys = "<C-x>";
            }
          ];
          clues = [
            { __raw = "require('mini.clue').gen_clues.builtin_completion()"; }
            { __raw = "require('mini.clue').gen_clues.g()"; }
            { __raw = "require('mini.clue').gen_clues.marks()"; }
            { __raw = "require('mini.clue').gen_clues.registers()"; }
            { __raw = "require('mini.clue').gen_clues.windows()"; }
            { __raw = "require('mini.clue').gen_clues.z()"; }
            {
              mode = "n";
              keys = "<Leader>f";
              desc = "+find";
            }
            {
              mode = "n";
              keys = "<Leader>b";
              desc = "+buffer";
            }
            {
              mode = "n";
              keys = "<Leader>c";
              desc = "+code";
            }
            {
              mode = "n";
              keys = "<Leader>g";
              desc = "+git";
            }
            {
              mode = "n";
              keys = "<Leader>r";
              desc = "+rename";
            }
            {
              mode = "n";
              keys = "<Leader>v";
              desc = "+visual-select";
            }
          ];
        };
        indentscope = { };
        diff = { };
        git = { };
        pairs = { };
        surround = { };
        comment = { };
        notify = { };
        hipatterns = { };
      };
    };

    noice.enable = true;
    todo-comments.enable = true;

    treesitter = {
      enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        go
        python
        javascript
        typescript
        tsx
        json
        yaml
        lua
        nix
        markdown
        markdown-inline
        bash
        html
        css
      ];
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    lsp = {
      enable = true;
      servers = {
        gopls.enable = true;
        pyright.enable = true;
        ts_ls.enable = true;
        nixd.enable = true;
      };
    };

    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        mapping = {
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<C-y>" = "cmp.mapping.confirm({ select = true })";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "buffer"; }
          { name = "path"; }
        ];
      };
    };
    cmp-nvim-lsp.enable = true;
    cmp-buffer.enable = true;
    cmp-path.enable = true;
    luasnip.enable = true;
    cmp_luasnip.enable = true;

    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_fallback = true;
          timeout_ms = 500;
        };
        formatters_by_ft = {
          go = [
            "goimports"
            "gofumpt"
          ];
          python = [
            "black"
            "isort"
          ];
          javascript = [ "oxfmt" ];
          typescript = [ "oxfmt" ];
          javascriptreact = [ "oxfmt" ];
          typescriptreact = [ "oxfmt" ];
          json = [ "oxfmt" ];
          yaml = [ "oxfmt" ];
          html = [ "oxfmt" ];
          css = [ "oxfmt" ];
        };
      };
    };

    lint = {
      enable = true;
      lintersByFt = {
        python = [ "ruff" ];
        javascript = [ "oxlint" ];
        javascriptreact = [ "oxlint" ];
        typescript = [ "oxlint" ];
        typescriptreact = [ "oxlint" ];
      };
    };

    lazygit.enable = true;
  };
}
