{ ... }: {
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    "image/gif" = [ "mpv.desktop" ];
    "image/jpeg" = [ "feh.desktop" "firefox.desktop" ];
    "image/jpg" = [ "feh.desktop" "firefox.desktop" ];
    "image/png" = [ "feh.desktop" "firefox.desktop" ];
    "image/webp" = [ "feh.desktop" "firefox.desktop" ];
    "inode/directory" = [ "firefox.desktop" ];
    "text/calendar" = [ "firefox.desktop" ];
    "text/html" = [ "firefox.desktop" ];
    "text/plain" = [ "firefox.desktop" ];
    "x-scheme-handler/about" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    "x-scheme-handler/webcal" = [ "firefox.desktop" ];
  };
}

