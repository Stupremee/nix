{ pkgs, lib, ... }: {
  systemd.user.timers.nix-index-db-update = {
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = 0;
    };
  };

  systemd.user.services.nix-index-db-update = {
    Unit = {
      Description = "nix-index database update";
      PartOf = [ "multi-user.target" ];
    };

    Service =
      let
        deps = with pkgs; [ nix-index libnotify ];
        script = pkgs.writeShellScript "nix-index-update-db" ''
          notify-send -i server-database nix-index "Starting nix-index database update"

          nix-index

          if [[ $? -eq 0 ]]; then
            notify-send -i server-database nix-index "Successfully updated nix-index database"
          else
            notify-send -i server-database nix-index "An error occurred while updating database"
          fi
        '';
      in
      {
        Environment = "PATH=${lib.makeBinPath deps}";
        ExecStart = "${script}";
      };
  };
}
