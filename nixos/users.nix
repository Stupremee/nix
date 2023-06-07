{...}: let
  # SSH keys for authentication
  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC25o7zyW1Jg3cIJau638oTdGcGM1pFalyGN27++nWhYQeeeE41MhbqBT05UMmkZkdKBfhpBOdQkbcki4ASlnFOLt1Bk67dWD6s0m0sslGtBIq9qLqoC81n1c3juQrF0UDg4Ww7oZ/7Ba6uWkVWOyAbiRYjjbKI/0ml/HYKVETj5XKxe8FBkC53MWh3b/tpMs/gvvAGSFwTexIeQXTz+sOvhASmNgIKntWa2eKd8sszOCYfl82dTZAx0eYsYgaL9p5mLH6XK/8KuIuDs5Rgz4P9APvO1o4HgEn3OrBQwZFog/aVDeOl0umDEw8+hbnEt7A7iaNXLnY9sQtRh+eq9HPaaJavtVI4AoqOJ30XzlQP5eCQUaFQ3RbqDVp1JAarh9SYvWeKPCSzFDHcYDBKp7x8hXcZl8inwwmExgJneryOXkUkmX9+FK7NruYNhVif3lcxlvHbx940olVk7gkBmwHmCrH4KVWWZ+UYS/m1rW6m/f9tKZigcuTBo+Pld3ZPLJQWZyJUi0xoKudo+cNpnDzZYSxEHjvaX7lxLEWNnYYh772A6vJRXw5hg8AuDsH+w9AyM7d/ZtIFVe232maAXl2qgBJZghBEs7VHje5908mXaXI4qgsa6itG3EqXHlWQ/tPxvDr/rAsBJnVtY2GMobnbj3vCFL0AmXjV04+pcmMBBw=="
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBaJhgjPCMsNf4xHk2DNJMRXdKfl7usg4dPDKrimD7hmV6UYWgOdXsS+g0eKvWadQ5FbiT6CsYO41vmvUlAZwm0="
  ];
in {
  users.users = {
    stu = {
      isNormalUser = true;
      home = "/home/stu";
      extraGroups = [
        "wheel"
        "dialout"
        "docker"
        "wireshark"
        "podman"
        "networkmanager"
        "video"
        "lp"
      ];
      uid = 1000;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  boot.initrd.network.ssh.authorizedKeys = keys;

  security.sudo.wheelNeedsPassword = false;
}
