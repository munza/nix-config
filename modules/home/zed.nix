_: {
  programs.zed-editor = {
    enable = true;

    userKeymaps = [ ];

    userSettings = {
      # ── Appearance ──────────────────────────────────────────────────────
      theme = {
        mode = "system";
        light = "Dayfox - opaque";
        dark = "Terafox - opaque";
      };

      # Icons come from the fallback family; see modules/home/ghostty.nix.
      ui_font_family = "Annotation Mono";
      ui_font_fallbacks = [ "Symbols Nerd Font Mono" ];
      ui_font_size = 16;

      buffer_font_family = "Annotation Mono";
      buffer_font_fallbacks = [ "Symbols Nerd Font Mono" ];
      buffer_font_size = 15;
      buffer_line_height = {
        custom = 1.6;
      };

      agent_ui_font_size = 16;
      agent_buffer_font_size = 15;

      # ── Editing ─────────────────────────────────────────────────────────
      vim_mode = true;
      vim = {
        cursor_shape = {
          normal = "hollow";
          insert = "bar";
        };
        toggle_relative_line_numbers = true;
      };

      tab_size = 2;
      format_on_save = "on";

      # ── Panels and docks ────────────────────────────────────────────────
      project_panel = {
        hide_hidden = false;
        hide_gitignore = false;
        hide_root = true;
        folder_icons = false;
        file_icons = true;
        entry_spacing = "comfortable";
      };

      outline_panel = {
        file_icons = false;
      };

      debugger = {
        dock = "bottom";
      };

      terminal = {
        dock = "bottom";
      };

      # ── AI ──────────────────────────────────────────────────────────────
      edit_predictions = {
        provider = "copilot";
      };

      agent = {
        # Send on cmd-enter, so plain enter inserts a newline.
        use_modifier_to_send = true;
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # ── Languages ───────────────────────────────────────────────────────
      # Per-language overrides; everything else takes the defaults above.
      languages = {
        Astro = {
          formatter = "language_server";
          tab_size = 2;
        };
        Lua = {
          formatter = {
            external = {
              command = "stylua";
              arguments = [
                "--syntax=Lua54"
                "--respect-ignores"
                "--stdin-filepath"
                "{buffer_path}"
                "-"
              ];
            };
          };
        };
        Nix = {
          # nixd over nil: it resolves flake attrs, nil does not.
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
      };

      lsp = {
        nixd = {
          initialization_options = {
            formatting = {
              command = [ "nixfmt" ];
            };
          };
        };
      };
    };
  };
}
