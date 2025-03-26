{
  flake,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.user;

  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC25o7zyW1Jg3cIJau638oTdGcGM1pFalyGN27++nWhYQeeeE41MhbqBT05UMmkZkdKBfhpBOdQkbcki4ASlnFOLt1Bk67dWD6s0m0sslGtBIq9qLqoC81n1c3juQrF0UDg4Ww7oZ/7Ba6uWkVWOyAbiRYjjbKI/0ml/HYKVETj5XKxe8FBkC53MWh3b/tpMs/gvvAGSFwTexIeQXTz+sOvhASmNgIKntWa2eKd8sszOCYfl82dTZAx0eYsYgaL9p5mLH6XK/8KuIuDs5Rgz4P9APvO1o4HgEn3OrBQwZFog/aVDeOl0umDEw8+hbnEt7A7iaNXLnY9sQtRh+eq9HPaaJavtVI4AoqOJ30XzlQP5eCQUaFQ3RbqDVp1JAarh9SYvWeKPCSzFDHcYDBKp7x8hXcZl8inwwmExgJneryOXkUkmX9+FK7NruYNhVif3lcxlvHbx940olVk7gkBmwHmCrH4KVWWZ+UYS/m1rW6m/f9tKZigcuTBo+Pld3ZPLJQWZyJUi0xoKudo+cNpnDzZYSxEHjvaX7lxLEWNnYYh772A6vJRXw5hg8AuDsH+w9AyM7d/ZtIFVe232maAXl2qgBJZghBEs7VHje5908mXaXI4qgsa6itG3EqXHlWQ/tPxvDr/rAsBJnVtY2GMobnbj3vCFL0AmXjV04+pcmMBBw=="
  ];
in
{
  options.my.user = {
    mainUser = mkOption {
      type = types.str;
      default = "stu";
    };

    root = {
      enable = mkEnableOption "Activate the root user";

      enablePassword = mkEnableOption "Activate login to root user via password.";
    };

    stu = {
      enable = mkEnableOption "Activate the main user";
      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra groups to put 'stu' into";
      };
    };
  };

  config = {
    users.users = {
      root = mkIf cfg.root.enable {
        openssh.authorizedKeys.keys = keys;

        hashedPassword = mkIf cfg.root.enablePassword "$y$j9T$88ErfFaSFvBV9lMG/4TVr.$Am5kfQJLXNlKAwNHLjcmSuW/yiIjjjin6010lrEr392";
      };

      stu = mkIf cfg.stu.enable {
        isNormalUser = true;
        home = "/home/stu";
        extraGroups = [
          "wheel"
        ] ++ cfg.stu.extraGroups;
        uid = 1000;
        openssh.authorizedKeys.keys = keys;

        hashedPassword = "$y$j9T$fq7cSllyiKjpR4nG2mzG31$5RNvNqLzQeVejRabNJ1eVnL.v5DQRTu0VLpS6HhHwc0";
      };
    };

    # Enable home-manager for our user
    home-manager.users.stu =
      let
        inherit (builtins) pathExists;

        name = "stu@${config.networking.hostName}";
        module = flake.inputs.self + /configurations/home/${name}.nix;
      in
      mkIf (pathExists module) {
        imports = [
          flake.inputs.self.homeModules.default
          module
        ];
      };

    nix.settings = mkIf cfg.stu.enable {
      allowed-users = [ "stu" ];
      trusted-users = [ "stu" ];
    };
  };
}
