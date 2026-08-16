_:

{
  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      format = ''
        $username$hostname$directory$git_branch$git_status$nix_shell$cmd_duration
        $character'';

      username = {
        show_always = false;
        format = "[$user]($style) ";
      };

      hostname = {
        ssh_only = true;
        format = "[@$hostname]($style) ";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
      };

      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
      };

      cmd_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };
    };
  };
}
