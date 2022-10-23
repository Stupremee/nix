{ pkgs, ... }: {
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        shrink = "no";
        padding = 20;
        horizontal_padding = 20;
        
        width = 275;
        height = 100;
        offset = "10x50";
        origin = "top-right";

        frame_width = 2;
        separator_height = 2;
        frame_color = "#161320";
        separator_color = "#161320";

        sort = "no";
        font = "monospace 10";
        markup = "full";
        format = "<b>%s</b>\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = "yes";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = "no";
        show_indicators = "yes";

        icon_position = "left";
        max_icon_size= 60;
        sticky_history = "no";
        history_length = 6;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 20;

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        background = "#1E1E2E";
        foreground = "#D9E0EE";
        frame_color = "#96CDFB";
        timeout = 5;
      };

      urgency_normal = {
        background = "#1E1E2E";
        frame_color = "#B5E8E0";
        foreground = "#D9E0EE";
        timeout = 10;
      };

      urgency_critical = {
        background = "#1E1E2E";
        frame_color = "#F88D96";
        foreground = "#D9E0EE";
        timeout = 20;
      };
    };
  };
}
