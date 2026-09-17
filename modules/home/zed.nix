_: {
  programs.zed-editor = {
    enable = true;
    # Zed itself comes from the Homebrew cask (auto-updating); this module
    # only manages settings.json/keymap.json, so skip the from-source nix build.
    package = null;

    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          "ctrl-h" = [
            "workspace::ActivatePaneInDirection"
            "Left"
          ];
          "ctrl-l" = [
            "workspace::ActivatePaneInDirection"
            "Right"
          ];
          "ctrl-k" = [
            "workspace::ActivatePaneInDirection"
            "Up"
          ];
          "ctrl-j" = [
            "workspace::ActivatePaneInDirection"
            "Down"
          ];
        };
      }
      {
        context = "Editor && vim_mode == normal";
        bindings = {
          # ── Panels: open + focus; pressing again while focused closes it ──
          # (must be `Toggle`, not `ToggleFocus` — ToggleFocus only ever moves
          # focus and never hides the panel)
          "space a a" = "agent::Toggle";
          "space f e" = "project_panel::Toggle";
          "space g g" = "git_panel::Toggle";
          "space d d" = "debug_panel::Toggle";
          "space t t" = "terminal_panel::Toggle";

          # ── LSP ─────────────────────────────────────────────────────────
          "g d" = "editor::GoToDefinition";
          "g D" = "editor::GoToDefinitionSplit";
          "g i" = "editor::GoToImplementation";
          "g r" = "editor::FindAllReferences";
          "space c a" = "editor::ToggleCodeActions";
          "space c r" = "editor::Rename";
          "space c f" = "editor::Format";

          # ── Diagnostics ─────────────────────────────────────────────────
          "] d" = "editor::GoToDiagnostic";
          "[ d" = "editor::GoToPreviousDiagnostic";
          "space x x" = "diagnostics::Deploy";

          # ── Git ─────────────────────────────────────────────────────────
          "space g d" = "git::Diff";
          "space g b" = "editor::ToggleGitBlameInline";
          "] h" = "editor::GoToHunk";
          "[ h" = "editor::GoToPreviousHunk";
          # Remote sync. Zed's Fetch pulls from the current branch's tracked
          # remote (there's no separate "fetch --all" action).
          "space g f" = "git::Fetch";
          "space g p" = "git::Push";
          "space g shift-p" = "git::ForcePush";
          "space g l" = "git::Pull";
          "space g shift-l" = "git::PullRebase";
          # Stage / unstage everything in one go.
          "space g s" = "git::StageAll";
          "space g u" = "git::UnstageAll";

          # ── Buffers / files ─────────────────────────────────────────────
          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          "ctrl-s" = "workspace::Save";
          "space f f" = "file_finder::Toggle";
        };
      }
      {
        context = "Editor && vim_mode == visual";
        bindings = {
          "g c" = "editor::ToggleComments";
        };
      }
      {
        # Space has a default binding (vim::WrappingRight) in Zed's stock vim
        # keymap, so which-key resolves it as soon as the delay elapses instead
        # of staying open like it does for "g", which has no standalone action.
        # Disabling it makes space a pure leader key.
        context = "VimControl && !menu";
        bindings = {
          "space" = null;
        };
      }
      {
        # Cycle focus between editor, open panels, and status bar (vim window-cycle style)
        context = "Workspace";
        bindings = {
          "ctrl-w w" = "workspace::FocusNextPart";
          "ctrl-w shift-w" = "workspace::FocusPreviousPart";
          "ctrl-\\" = "terminal_panel::Toggle";
        };
      }
      {
        # Navigate suggestion/completion/picker lists without arrow keys
        # (ctrl-n/ctrl-p already work by default; these add ctrl-j/ctrl-k aliases
        # to match the ctrl-hjkl pane-navigation muscle memory used above).
        context = "menu";
        bindings = {
          "ctrl-j" = "menu::SelectNext";
          "ctrl-k" = "menu::SelectPrevious";
        };
      }
      {
        # "q" to close, netrw-style — scoped to not_editing so renaming still works
        context = "ProjectPanel && not_editing";
        bindings = {
          "q" = "project_panel::Toggle";
        };
      }
      {
        # `!Editor` keeps this from firing while typing in the commit
        # message box (a nested Editor context) — only closes when browsing
        # the changes list itself.
        context = "GitPanel && !Editor";
        bindings = {
          "q" = "git_panel::Toggle";
        };
      }
      {
        # `!Editor` excludes the chat composer, same reasoning as GitPanel above.
        context = "AgentPanel && !Editor";
        bindings = {
          "q" = "agent::Toggle";
        };
      }
      {
        # `!Editor` excludes the debug console input.
        context = "DebugPanel && !Editor";
        bindings = {
          "q" = "debug_panel::Toggle";
        };
      }
    ];

    userSettings = {
      # ── Appearance ──────────────────────────────────────────────────────
      theme = {
        mode = "system";
        light = "Dayfox - opaque";
        dark = "Nightfox - opaque";
      };

      # Icons come from the fallback family; see modules/home/ghostty.nix.
      ui_font_family = "Comic Code Ligatures";
      ui_font_fallbacks = [ "Symbols Nerd Font Mono" ];
      buffer_font_family = "Comic Code Ligatures";
      buffer_font_fallbacks = [ "Symbols Nerd Font Mono" ];

      ui_font_size = 16;
      buffer_font_size = 15;
      agent_ui_font_size = 16;
      agent_buffer_font_size = 15;

      use_system_window_tabs = true;
      show_whitespaces = "trailing";

      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };

      # ── Editing ─────────────────────────────────────────────────────────
      vim_mode = true;
      vim = {
        cursor_shape = {
          normal = "hollow";
          insert = "bar";
        };
        toggle_relative_line_numbers = true;
      };
      relative_line_numbers = "enabled";
      which_key = {
        enabled = true;
        delay_ms = 200;
      };

      tab_size = 2;
      format_on_save = "on";
      vertical_scroll_margin = 4;
      horizontal_scroll_margin = 8;

      colorize_brackets = true;
      code_lens = "menu";
      toolbar.code_actions = true;
      show_signature_help_after_edits = false;
      auto_signature_help = false;
      show_edit_predictions = true;

      # ── Privacy / session ───────────────────────────────────────────────
      redact_private_values = true;
      session.trust_all_worktrees = true;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # ── Panels and docks ────────────────────────────────────────────────
      cli_default_open_behavior = "existing_window";
      gutter.line_numbers = true;
      status_bar.show_active_file = false;
      debugger.dock = "bottom";
      terminal.dock = "bottom";
      file_finder.modal_max_width = "large";
      file_scan_exclusions = [
        "**/.git"
        "**/.svn"
        "**/.hg"
        "**/CVS"
        "**/.DS_Store"
        "**/Thumbs.db"
        "**/.classpath"
        "**/.settings"
        "**/node_modules"
        "**/dist"
        "**/out"
        "**/.next"
        "**/.turbo"
      ];

      project_panel = {
        hide_hidden = false;
        hide_gitignore = false;
        hide_root = true;
        folder_icons = false;
        file_icons = true;
        entry_spacing = "comfortable";
        git_status_indicator = true;
        diagnostic_badges = true;
        show_diagnostics = "errors";
        auto_fold_dirs = false;
      };

      git.inline_blame.enabled = true;
      git_panel = {
        collapse_untracked_diff = true;
        show_count_badge = true;
        diff_stats = true;
        file_icons = true;
        tree_view = true;
        dock = "right";
      };

      tabs = {
        file_icons = true;
        git_status = true;
        show_diagnostics = "errors";
      };

      # ── AI ──────────────────────────────────────────────────────────────
      edit_predictions = {
        model = "subtle";
        provider = "copilot";
      };

      agent = {
        dock = "left";
        use_modifier_to_send = true;
        single_file_review = true;
        agent_follow = true;
      };

      # ── Languages ───────────────────────────────────────────────────────
      # Per-language overrides; everything else takes the defaults above.
      languages = {
        Lua.formatter.external = {
          command = "stylua";
          arguments = [
            "--syntax=Lua54"
            "--respect-ignores"
            "--stdin-filepath"
            "{buffer_path}"
            "-"
          ];
        };
        Nix.language_servers = [
          "nixd"
          "!nil"
        ];
      };

      lsp = {
        nixd.initialization_options.formatting = {
          command = [ "nixfmt" ];
        };
      };
    };
  };
}
