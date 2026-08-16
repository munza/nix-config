_: {
  programs.zed-editor = {
    enable = true;

    userKeymaps = [
      {
        context = "ProjectPanel && not_editing";
        bindings = {
          "q" = "workspace::ToggleLeftDock";
        };
      }
      {
        context = "GitPanel";
        bindings = {
          "q" = "workspace::ToggleLeftDock";
        };
      }
    ];

    userSettings = {
      edit_predictions = {
        provider = "copilot";
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

      agent = {
        use_modifier_to_send = true;
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      project_panel = {
        hide_hidden = false;
        folder_icons = false;
        file_icons = true;
        entry_spacing = "comfortable";
        hide_gitignore = false;
        hide_root = true;
      };

      vim_mode = true;
      vim = {
        cursor_shape = {
          normal = "hollow";
          insert = "bar";
        };
        toggle_relative_line_numbers = true;
      };

      ui_font_size = 16;
      ui_font_family = "AnnotationM Nerd Font";
      buffer_font_size = 15;
      buffer_font_family = "AnnotationM Nerd Font";
      agent_ui_font_size = 16;
      agent_buffer_font_size = 15;
      buffer_line_height = {
        custom = 1.6;
      };

      theme = {
        mode = "system";
        light = "Dayfox - opaque";
        dark = "Terafox - opaque";
      };

      languages = {
        Astro = {
          formatter = "language_server";
          tab_size = 2;
        };
        Rust = {
          tab_size = 4;
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
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
      };

      tab_size = 2;
      format_on_save = "on";

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
