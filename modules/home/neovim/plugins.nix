# Neovim plugins
#
# mini.nvim covers most of what would otherwise be a dozen separate plugins
# (statusline, file explorer, picker, surround, comment, git signs), so it is
# the bulk of this file. Everything after it is a gap mini does not fill.
{ pkgs, ... }:

let
  # js-debug wants the same shape for every node configuration.
  nodeLaunch = name: {
    inherit name;
    type = "pwa-node";
    request = "launch";
    program = "\${file}";
    cwd = "\${workspaceFolder}";
    sourceMaps = true;
  };
in
{
  programs.nixvim.plugins = {
    # ── mini.nvim ───────────────────────────────────────────────────────
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
        # Popup showing what each pending key does; triggers list the prefixes
        # that open it, clues name the groups.
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
            {
              mode = "n";
              keys = "<Leader>d";
              desc = "+debug";
            }
            {
              mode = "n";
              keys = "<Leader>a";
              desc = "+ai";
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

    # ── UI ──────────────────────────────────────────────────────────────
    noice.enable = true;
    todo-comments.enable = true;

    # ── Syntax ──────────────────────────────────────────────────────────
    # Grammars are pinned here rather than fetched at runtime, so a new
    # language means adding it to this list.
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

    # ── LSP ─────────────────────────────────────────────────────────────
    lsp = {
      enable = true;
      servers = {
        gopls.enable = true;
        pyright.enable = true;
        ts_ls.enable = true;
        nixd.enable = true;
      };
    };

    # ── Completion ──────────────────────────────────────────────────────
    # cmp plus its sources; the order of `sources` is the priority order.
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

    # ── Formatting ──────────────────────────────────────────────────────
    # Formats on save, falling back to the language server when no formatter
    # is configured for the filetype.
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

    # ── Linting ─────────────────────────────────────────────────────────
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

    # ── Debugging ───────────────────────────────────────────────────────
    # dap is the engine; the ui and virtual-text plugins are what make it
    # usable. Adapters live in extraPackages so nvim finds them without the
    # host shell needing them.
    dap = {
      enable = true;
      adapters.servers.pwa-node = {
        host = "localhost";
        port = "\${port}";
        executable = {
          command = "js-debug";
          args = [ "\${port}" ];
        };
      };
      configurations = {
        javascript = [ (nodeLaunch "Launch file") ];
        typescript = [ (nodeLaunch "Launch file") ];
      };
    };

    dap-ui = {
      enable = true;
      # Open on the first breakpoint and close when the session ends, so the
      # panels are not permanently eating screen space.
      settings.controls.enabled = true;
    };

    dap-virtual-text.enable = true;

    # Language wrappers: these register their own adapters and configurations.
    dap-go.enable = true;
    dap-python = {
      enable = true;
      settings.include_configs = true;
    };

    # ── AI ──────────────────────────────────────────────────────────────
    # Inline suggestions only. Completion stays with cmp: routing copilot
    # through cmp as well would show every suggestion twice.
    copilot-lua = {
      enable = true;
      settings = {
        suggestion = {
          enabled = true;
          auto_trigger = true;
          keymap = {
            accept = "<C-l>";
            next = "<C-.>";
            prev = "<C-,>";
            dismiss = "<C-]>";
          };
        };
        panel.enabled = false;
        # Not a completion source here, and it should stay out of these.
        filetypes = {
          gitcommit = false;
          gitrebase = false;
        };
      };
    };

    # claude-code runs as a CLI in a float; it keeps its own login, so there
    # is no API key for nvim to hold. The terminal is created once and reused,
    # so toggling back returns to the same session rather than a new one.
    toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        float_opts.border = "curved";
      };
      luaConfig.post = ''
        _CLAUDE_CODE = require("toggleterm.terminal").Terminal:new({
          cmd = "claude",
          direction = "float",
          float_opts = { border = "curved" },
          -- Land in insert mode: the whole point is to start typing.
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.keymap.set("t", "<C-q>", "<cmd>close<CR>", { buffer = term.bufnr })
          end,
        })
      '';
    };

    # ── Git ─────────────────────────────────────────────────────────────
    lazygit.enable = true;
  };
}
