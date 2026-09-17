{ inputs, pkgs, ... }:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;

    # Space as leader must be set before any `<leader>`-based keymap is
    # defined below, since `<leader>` is expanded to this value at the point
    # each mapping is created.
    globals.mapleader = " ";

    opts = {
      # How long Neovim waits on an ambiguous key sequence (e.g. after
      # pressing <leader>) before giving up and treating it as final.
      timeoutlen = 300;

      # Hybrid line numbers: absolute on the current line, relative elsewhere.
      number = true;
      relativenumber = true;

      # Folding (treesitter.folding.enable below) defaults to foldlevel=0,
      # i.e. everything collapsed on open. Start fully unfolded instead;
      # za/zc/zo etc. still work for manual folding.
      foldlevel = 99;
      foldlevelstart = 99;

      # 4-space indentation (Neovim defaults all of these to 8).
      tabstop = 4; # width of a literal tab character
      shiftwidth = 4; # spaces per (auto)indent step
      softtabstop = 4; # Tab/Backspace edit 4 spaces at a time
      expandtab = true; # insert spaces instead of literal tabs
    };

    # Terafox/Dayfox everywhere (see ghostty.nix, zed.nix). Unlike rose-pine,
    # nightfox has no single "auto" colorscheme — terafox (dark) and dayfox
    # (light) are separate colorschemes, so auto-dark-mode-nvim below
    # re-sources whichever one matches macOS's appearance directly.
    colorschemes.nightfox = {
      enable = true;
      flavor = "nightfox";
    };

    # No nixvim module for this plugin, so it's wired in by hand.
    extraPlugins = [ pkgs.vimPlugins.auto-dark-mode-nvim ];
    extraConfigLua = ''
      require("auto-dark-mode").setup({
        set_dark_mode = function()
          vim.o.background = "dark"
          vim.cmd.colorscheme("nightfox")
        end,
        set_light_mode = function()
          vim.o.background = "light"
          vim.cmd.colorscheme("dayfox")
        end,
      })
    '';

    plugins = {
      # Icon provider other mini.nvim UI plugins render through.
      mini-icons.enable = true;

      # Navigation
      mini-pick.enable = true;
      mini-files.enable = true;
      mini-bracketed.enable = true;
      mini-extra.enable = true;
      mini-sessions.enable = true;

      # UI
      mini-statusline.enable = true;
      mini-tabline.enable = true;
      mini-cursorword.enable = true;
      mini-notify.enable = true;
      mini-animate.enable = true;

      # Discoverability: pop a which-key-style popup on <leader>, g, marks,
      # registers, windows and z, showing every keymap's `desc` under it.
      mini-clue = {
        enable = true;
        settings = {
          window = {
            delay = 250;
            # Fixed width (30) by default; size to content instead.
            config.width = "auto";
          };

          triggers = [
            {
              mode = [
                "n"
                "x"
              ];
              keys = "<leader>";
            }
            {
              mode = [
                "n"
                "x"
              ];
              keys = "g";
            }
            {
              mode = [
                "n"
                "x"
              ];
              keys = "'";
            }
            {
              mode = [
                "n"
                "x"
              ];
              keys = "`";
            }
            {
              mode = [
                "n"
                "x"
              ];
              keys = "\"";
            }
            {
              mode = [
                "n"
                "x"
              ];
              keys = "[";
            }
            {
              mode = [
                "n"
                "x"
              ];
              keys = "]";
            }
            {
              mode = [
                "n"
                "x"
              ];
              keys = "s";
            }

            {
              mode = "i";
              keys = "<C-r>";
            }
            {
              mode = "c";
              keys = "<C-r>";
            }
            {
              mode = "i";
              keys = "<C-x>";
            }
            {
              mode = "n";
              keys = "<C-w>";
            }
            {
              mode = "n";
              keys = "z";
            }
            {
              mode = "x";
              keys = "z";
            }
          ];
          clues = [
            { __raw = "require('mini.clue').gen_clues.builtin_completion()"; }
            { __raw = "require('mini.clue').gen_clues.g()"; }
            { __raw = "require('mini.clue').gen_clues.square_brackets()"; }
            { __raw = "require('mini.clue').gen_clues.marks()"; }
            { __raw = "require('mini.clue').gen_clues.registers()"; }
            { __raw = "require('mini.clue').gen_clues.windows()"; }
            { __raw = "require('mini.clue').gen_clues.z()"; }

            # Titles for our own <leader> groups, instead of "+N choices".
            {
              mode = "n";
              keys = "<leader>b";
              desc = "+Buffer";
            }
            {
              mode = "n";
              keys = "<leader>f";
              desc = "+Find";
            }
            {
              mode = "n";
              keys = "<leader>h";
              desc = "+Help";
            }
            {
              mode = "n";
              keys = "<leader>l";
              desc = "+LSP";
            }
            {
              mode = "n";
              keys = "<leader>s";
              desc = "+Session";
            }
            {
              mode = "n";
              keys = "<leader>v";
              desc = "+Visual";
            }
            {
              mode = "n";
              keys = "<leader>w";
              desc = "+Window";
            }
            {
              mode = "n";
              keys = "<leader>m";
              desc = "+Markdown";
            }

            # Repeat these <leader>w actions without re-pressing the prefix:
            # e.g. <leader>w then hh l jj keeps navigating/resizing.
            {
              mode = "n";
              keys = "<leader>wh";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wj";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wk";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wl";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>ww";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>w+";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>w-";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>w<";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>w>";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wH";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wJ";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wK";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wL";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wx";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wr";
              postkeys = "<leader>w";
            }
            {
              mode = "n";
              keys = "<leader>wR";
              postkeys = "<leader>w";
            }
          ];
        };
      };

      # Editing
      mini-pairs.enable = true;
      mini-surround.enable = true;
      mini-comment.enable = true;
      mini-ai.enable = true;
      mini-indentscope.enable = true;
      mini-splitjoin.enable = true;
      mini-move.enable = true;
      mini-jump.enable = true;
      mini-jump2d.enable = true;
      mini-trailspace.enable = true;
      mini-align.enable = true;
      mini-bufremove.enable = true;

      # As-you-type completion. lsp_completion.auto_setup defaults to true,
      # so it wires itself into whatever LSP client is attached automatically.
      mini-completion.enable = true;

      # Startup dashboard: builtin actions, recent files, and saved sessions
      # (the last section ties into mini-sessions, written via <leader>ss).
      mini-starter = {
        enable = true;
        settings.items = [
          { __raw = "require('mini.starter').sections.builtin_actions()"; }
          { __raw = "require('mini.starter').sections.recent_files(10, false)"; }
          { __raw = "require('mini.starter').sections.recent_files(10, true)"; }
          { __raw = "require('mini.starter').sections.sessions(5, true)"; }
        ];
      };

      # Highlighting: TODO/FIXME/HACK/NOTE markers and hex color previews.
      mini-hipatterns = {
        enable = true;
        settings.highlighters = {
          fixme = {
            pattern = "%f[%w]()FIXME()%f[%W]";
            group = "MiniHipatternsFixme";
          };
          hack = {
            pattern = "%f[%w]()HACK()%f[%W]";
            group = "MiniHipatternsHack";
          };
          todo = {
            pattern = "%f[%w]()TODO()%f[%W]";
            group = "MiniHipatternsTodo";
          };
          note = {
            pattern = "%f[%w]()NOTE()%f[%W]";
            group = "MiniHipatternsNote";
          };
          hex_color.__raw = "require('mini.hipatterns').gen_highlighter.hex_color()";
        };
      };

      # Git
      # style defaults to 'number' (colors the line number) when `number`
      # is on, 'sign' (gutter icon) otherwise. Force sign icons either way.
      mini-diff = {
        enable = true;
        settings.view.style = "sign";
      };
      mini-git.enable = true;

      # Formatting (bound to <leader>lf below): conform runs an external
      # formatter per filetype and falls back to the attached LSP server
      # when none is configured (gopls for Go, rust-analyzer for Rust).
      # autoInstall adds the formatter binaries to the Neovim closure.
      conform-nvim = {
        enable = true;
        autoInstall.enable = true;
        settings.formatters_by_ft = {
          nix = [ "nixfmt" ];
          lua = [ "stylua" ];
          python = [ "ruff_format" ];
          # `mix` (below) auto-installs an elixir into Neovim's PATH, but the
          # project's own toolchain wins inside a devenv/direnv shell.
          elixir = [ "mix" ];
          sh = [ "shfmt" ];
          bash = [ "shfmt" ];
          markdown = [ "prettierd" ];
          json = [ "prettierd" ];
          jsonc = [ "prettierd" ];
          yaml = [ "prettierd" ];
          html = [ "prettierd" ];
          css = [ "prettierd" ];
          javascript = [ "prettierd" ];
          javascriptreact = [ "prettierd" ];
          typescript = [ "prettierd" ];
          typescriptreact = [ "prettierd" ];
        };
      };

      # Markdown: pretty in-buffer preview (headings, tables, checkboxes,
      # code blocks) rendered by default on markdown buffers. Editing still
      # works while rendered; <leader>mp toggles raw source ↔ preview.
      render-markdown.enable = true;

      # Language support: syntax-aware highlighting, indentation and folding.
      # nixvim's default is every grammar ever built, which drags evaluation
      # and closure size for languages never opened; pinned to the stacks
      # this config actually installs (plus markup/config everywhere).
      treesitter = {
        enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          # Languages with toolchains in host-packages.nix
          bash
          elixir
          go
          javascript
          json
          lua
          python
          rust
          toml
          tsx
          typescript
          yaml

          # Markup and config that every project touches
          css
          dockerfile
          html
          markdown
          markdown_inline
          nix
          query
          regex
          vim
          vimdoc
        ];
        highlight.enable = true;
        indent.enable = true;
        folding.enable = true;
      };

      # Supplies default cmd/filetypes/root_markers for named servers (nixd,
      # bashls, etc.) into vim.lsp.config. Does not enable/start anything
      # itself — that's lsp.servers.*.enable below, via vim.lsp.enable().
      lspconfig.enable = true;
    };

    # Neovim's own native LSP config (vim.lsp.enable), no nvim-lspconfig
    # plugin needed. Buffer-local keymaps below only attach once a server
    # actually does — Neovim's own built-in gr*/gO/gd already cover
    # rename/code-action/references/implementation/type-def/symbols.
    lsp = {
      # Inlay hints (types, params, chaining) for servers that support them —
      # rust-analyzer, gopls, lua_ls, etc.
      inlayHints.enable = true;

      servers = {
        nixd.enable = true;
        bashls.enable = true;
        lua_ls.enable = true;
        ts_ls.enable = true;
        basedpyright.enable = true;
        # Linter/formatter half of the Python story; basedpyright above
        # stays the type checker.
        ruff.enable = true;
        # Elixir: lexical's successor (lexical itself was archived upstream
        # and removed from nixpkgs).
        expert.enable = true;
        gopls.enable = true;
        rust_analyzer = {
          enable = true;
          # Server settings live under the "rust-analyzer" key, not at the
          # top level. See https://rust-analyzer.github.io/book/configuration.html
          config."rust-analyzer" = {
            # Clippy instead of plain `cargo check` for on-save diagnostics.
            check.command = "clippy";
            # Analyze all #[cfg(feature)] combinations of workspace crates.
            cargo.features = "all";
          };
        };
      };

      keymaps = [
        {
          key = "K";
          lspBufAction = "hover";
          options.desc = "Hover";
        }
        {
          key = "<leader>ld";
          lspBufAction = "definition";
          options.desc = "Definition";
        }
        {
          key = "<leader>lD";
          lspBufAction = "declaration";
          options.desc = "Declaration";
        }
        {
          key = "<leader>lr";
          lspBufAction = "references";
          options.desc = "References";
        }
        {
          key = "<leader>lR";
          lspBufAction = "rename";
          options.desc = "Rename symbol";
        }
        {
          key = "<leader>li";
          lspBufAction = "implementation";
          options.desc = "Implementation";
        }
        {
          key = "<leader>lt";
          lspBufAction = "type_definition";
          options.desc = "Type definition";
        }
      ];
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>lua MiniPick.builtin.files()<CR>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>lua MiniPick.builtin.grep_live()<CR>";
        options.desc = "Live grep";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>lua MiniPick.builtin.buffers()<CR>";
        options.desc = "Find buffers";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>lua MiniPick.builtin.help()<CR>";
        options.desc = "Help tags";
      }
      {
        mode = "n";
        key = "<leader>fe";
        action = "<cmd>lua if MiniFiles.close() == nil then MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end<CR>";
        options.desc = "Toggle file explorer";
      }
      {
        mode = "n";
        key = "<leader>fo";
        action = "<cmd>lua MiniExtra.pickers.oldfiles()<CR>";
        options.desc = "Recent files";
      }
      {
        mode = "n";
        key = "<leader>dd";
        action = "<cmd>lua MiniExtra.pickers.diagnostics({ scope = 'all' })<CR>";
        options.desc = "Diagnostics (all buffers)";
      }
      {
        mode = "n";
        key = "<leader>fB";
        action = "<cmd>lua MiniExtra.pickers.git_branches()<CR>";
        options.desc = "Git branches";
      }
      {
        mode = "n";
        key = "<leader>hk";
        action = "<cmd>lua MiniExtra.pickers.keymaps()<CR>";
        options.desc = "Keymaps";
      }

      # Format via conform (see conform-nvim above): runs the filetype's
      # external formatter, or the LSP server's when none is configured.
      {
        mode = "n";
        key = "<leader>lf";
        action.__raw = ''
          function()
            require("conform").format({ async = true, lsp_format = "fallback" })
          end
        '';
        options.desc = "Format buffer";
      }

      # Markdown preview ↔ raw source (see render-markdown above).
      {
        mode = "n";
        key = "<leader>mp";
        action = "<cmd>RenderMarkdown toggle<CR>";
        options.desc = "Toggle markdown preview";
      }

      # Aliases into the real ' and " triggers (remap=true so the fed key
      # re-enters mini.clue's own mapping — same popup, marks/registers).
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>'";
        action = "'";
        options = {
          remap = true;
          desc = "+Jump";
        };
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>\"";
        action = "\"";
        options = {
          remap = true;
          desc = "+Yank/Paste";
        };
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>`";
        action = "`";
        options = {
          remap = true;
          desc = "+Jump (exact)";
        };
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>[";
        action = "[";
        options = {
          remap = true;
          desc = "+Previous";
        };
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>]";
        action = "]";
        options = {
          remap = true;
          desc = "+Next";
        };
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>z";
        action = "z";
        options = {
          remap = true;
          desc = "+Fold/scroll";
        };
      }

      # Alias into the real g trigger (remap=true so the fed key re-enters
      # mini.clue's own g mapping — same popup as bare g).
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>g";
        action = "g";
        options = {
          remap = true;
          desc = "+Go-to";
        };
      }
      {
        mode = "n";
        key = "<leader>ss";
        action = "<cmd>lua MiniSessions.write('Session.vim', { force = true })<CR>";
        options.desc = "Save session (cwd)";
      }
      {
        mode = "n";
        key = "<leader>sl";
        action = "<cmd>lua MiniSessions.select()<CR>";
        options.desc = "Load session";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>lua MiniBufremove.delete()<CR>";
        options.desc = "Delete buffer";
      }
      {
        mode = "n";
        key = "<leader>bw";
        action = "<cmd>lua MiniBufremove.wipeout()<CR>";
        options.desc = "Wipeout buffer";
      }
      {
        mode = "n";
        key = "<leader>bn";
        action = "<cmd>bnext<CR>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = "<cmd>bprevious<CR>";
        options.desc = "Previous buffer";
      }

      # Window management, mirroring <C-w>'s own sub-commands via `wincmd`
      # so muscle memory transfers; just reachable through <leader>w too.
      {
        mode = "n";
        key = "<leader>wh";
        action = "<cmd>wincmd h<CR>";
        options.desc = "Focus left";
      }
      {
        mode = "n";
        key = "<leader>wj";
        action = "<cmd>wincmd j<CR>";
        options.desc = "Focus down";
      }
      {
        mode = "n";
        key = "<leader>wk";
        action = "<cmd>wincmd k<CR>";
        options.desc = "Focus up";
      }
      {
        mode = "n";
        key = "<leader>wl";
        action = "<cmd>wincmd l<CR>";
        options.desc = "Focus right";
      }
      {
        mode = "n";
        key = "<leader>ww";
        action = "<cmd>wincmd w<CR>";
        options.desc = "Focus next window";
      }
      {
        mode = "n";
        key = "<leader>ws";
        action = "<cmd>split<CR>";
        options.desc = "Split horizontal";
      }
      {
        mode = "n";
        key = "<leader>wv";
        action = "<cmd>vsplit<CR>";
        options.desc = "Split vertical";
      }
      {
        mode = "n";
        key = "<leader>wH";
        action = "<cmd>wincmd H<CR>";
        options.desc = "Move to far left";
      }
      {
        mode = "n";
        key = "<leader>wJ";
        action = "<cmd>wincmd J<CR>";
        options.desc = "Move to far bottom";
      }
      {
        mode = "n";
        key = "<leader>wK";
        action = "<cmd>wincmd K<CR>";
        options.desc = "Move to far top";
      }
      {
        mode = "n";
        key = "<leader>wL";
        action = "<cmd>wincmd L<CR>";
        options.desc = "Move to far right";
      }
      {
        mode = "n";
        key = "<leader>w+";
        action = "<cmd>wincmd +<CR>";
        options.desc = "Increase height";
      }
      {
        mode = "n";
        key = "<leader>w-";
        action = "<cmd>wincmd -<CR>";
        options.desc = "Decrease height";
      }
      {
        mode = "n";
        key = "<leader>w<";
        action = "<cmd>wincmd <<CR>";
        options.desc = "Decrease width";
      }
      {
        mode = "n";
        key = "<leader>w>";
        action = "<cmd>wincmd ><CR>";
        options.desc = "Increase width";
      }
      {
        mode = "n";
        key = "<leader>w=";
        action = "<cmd>wincmd =<CR>";
        options.desc = "Equalize sizes";
      }
      {
        mode = "n";
        key = "<leader>wx";
        action = "<cmd>wincmd x<CR>";
        options.desc = "Exchange with next";
      }
      {
        mode = "n";
        key = "<leader>wr";
        action = "<cmd>wincmd r<CR>";
        options.desc = "Rotate down/right";
      }
      {
        mode = "n";
        key = "<leader>wR";
        action = "<cmd>wincmd R<CR>";
        options.desc = "Rotate up/left";
      }
      {
        mode = "n";
        key = "<leader>wo";
        action = "<cmd>wincmd o<CR>";
        options.desc = "Close all but current";
      }
      {
        mode = "n";
        key = "<leader>wc";
        action = "<cmd>wincmd c<CR>";
        options.desc = "Close";
      }
      {
        mode = "n";
        key = "<leader>wq";
        action = "<cmd>wincmd q<CR>";
        options.desc = "Quit current";
      }
      {
        mode = "n";
        key = "<leader>wp";
        action = "<cmd>wincmd p<CR>";
        options.desc = "Focus last accessed";
      }
      {
        mode = "n";
        key = "<leader>wn";
        action = "<cmd>wincmd n<CR>";
        options.desc = "Open new";
      }

      # U is "undo line" by default (rarely used); repoint it at redo instead,
      # matching u/undo symmetry.
      {
        mode = "n";
        key = "U";
        action = "<C-r>";
        options.desc = "Redo";
      }
      # Visual mode entry + mini.surround (aliased into real s trigger).
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>vv";
        action = "v";
        options = {
          remap = true;
          desc = "Visual (charwise)";
        };
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>vV";
        action = "V";
        options = {
          remap = true;
          desc = "Visual (linewise)";
        };
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>vb";
        action = "<C-v>";
        options = {
          remap = true;
          desc = "Visual (blockwise)";
        };
      }
      {
        mode = "n";
        key = "<leader>vg";
        action = "<cmd>normal! gv<CR>";
        options.desc = "Reselect last visual";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>vs";
        action = "s";
        options = {
          remap = true;
          desc = "+Surround";
        };
      }

      # mini.ai textobjects. i/a only mean "inside"/"around" once already in
      # visual (or operator-pending) mode, so these enter visual first (v)
      # then hand off — normal mode only, since bare v means something
      # different if already in visual mode.
      {
        mode = "n";
        key = "<leader>vi";
        action = "vi";
        options = {
          remap = true;
          desc = "+Inside textobject";
        };
      }
      {
        mode = "n";
        key = "<leader>va";
        action = "va";
        options = {
          remap = true;
          desc = "+Around textobject";
        };
      }
    ];
  };
}
