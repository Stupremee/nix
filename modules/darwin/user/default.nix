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
    name = mkOption {
      type = types.str;
    };

    import = mkOption {
      type = types.path;
    };
  };

  config = {
    users.users.${cfg.name}.home = "/Users/${cfg.name}";
    home-manager.users.${cfg.name} = {
      imports = [ cfg.import ];
    };

    nix.settings = {
      allowed-users = [ cfg.name ];
      trusted-users = [ cfg.name ];
    };
  };
}
