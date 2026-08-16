_:

{
  programs.zellij = {
    enable = true;

    settings = {
      default_layout = "default";
      on_force_close = "quit";
      pane_frames = true;
      session_serialization = false;
      show_startup_tips = false;
      simplified_ui = true;
      theme = "terafox";
      ui.pane_frames.hide_session_name = true;
    };
  };

  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
        pane size=1 borderless=true {
            plugin location="zellij:compact-bar"
        }
        pane split_direction="vertical" {
            pane
        }
        pane size=1 borderless=true {
            plugin location="zellij:status-bar" {
                simplified_ui true
            }
        }
    }
  '';
}
