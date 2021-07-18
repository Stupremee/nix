{ ... }: {
  services.udev.extraRules = ''
    ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"
  '';

  systemd.tmpfiles.rules = [
    "D /media 0755 root root 0 -"
  ];
}
