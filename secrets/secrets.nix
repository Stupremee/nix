let
  users = [
    # My yubikey public key
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC25o7zyW1Jg3cIJau638oTdGcGM1pFalyGN27++nWhYQeeeE41MhbqBT05UMmkZkdKBfhpBOdQkbcki4ASlnFOLt1Bk67dWD6s0m0sslGtBIq9qLqoC81n1c3juQrF0UDg4Ww7oZ/7Ba6uWkVWOyAbiRYjjbKI/0ml/HYKVETj5XKxe8FBkC53MWh3b/tpMs/gvvAGSFwTexIeQXTz+sOvhASmNgIKntWa2eKd8sszOCYfl82dTZAx0eYsYgaL9p5mLH6XK/8KuIuDs5Rgz4P9APvO1o4HgEn3OrBQwZFog/aVDeOl0umDEw8+hbnEt7A7iaNXLnY9sQtRh+eq9HPaaJavtVI4AoqOJ30XzlQP5eCQUaFQ3RbqDVp1JAarh9SYvWeKPCSzFDHcYDBKp7x8hXcZl8inwwmExgJneryOXkUkmX9+FK7NruYNhVif3lcxlvHbx940olVk7gkBmwHmCrH4KVWWZ+UYS/m1rW6m/f9tKZigcuTBo+Pld3ZPLJQWZyJUi0xoKudo+cNpnDzZYSxEHjvaX7lxLEWNnYYh772A6vJRXw5hg8AuDsH+w9AyM7d/ZtIFVe232maAXl2qgBJZghBEs7VHje5908mXaXI4qgsa6itG3EqXHlWQ/tPxvDr/rAsBJnVtY2GMobnbj3vCFL0AmXjV04+pcmMBBw== openpgp:0x45DDDA9E"
    # 'stu' user on nixius
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvqrTPxGmyNg2lwwJsWVOl+MGwUVQBSiy+XRgqYQo0Q stu@nixius"
    # 'stu' user on leina
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGUYCcF9FMOIisnGBCOPXZt8hheVihO7PLJUmZY4erb6 stu@leina"
  ];

  systems = {
    nixius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO00K3mafb7j76+ZhBVYUHMHiCIKAxW+rvB4Uye97/yx root@nixius";
    aether = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEBk6IgHLPu7ST2HjugGHHFSlJSxUAA/d1AdDNx31lf root@aether";
    leina = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMGo71eRsJruqzg2THB/reAql3wpkON0LxrZ43LmVGX root@localhost";
  };

  keysForSystem = system: users ++ [ systems."${system}" ];
  keysForSystems = list: users ++ (builtins.map (s: systems."${s}") list);
  keysForAll = users ++ (builtins.attrValues systems);
in
{
  "tryHackMe.ovpn".publicKeys = keysForSystem "nixius";
  "esyon.ovpn".publicKeys = keysForSystem "nixius";

  "ssh.config".publicKeys = keysForSystems [ "nixius" "leina" ];
  "vaultwarden.ini".publicKeys = keysForSystem "aether";
  "paperlessPassword".publicKeys = keysForSystem "aether";
  "initDatabase.sql".publicKeys = keysForSystem "aether";
  "firefly.env".publicKeys = keysForSystem "aether";

  # Backup secrets
  "restic-important".publicKeys = keysForSystem "aether";
  "rclone.conf".publicKeys = keysForSystem "aether";

  # SSL certificates
  "cert/stu-dev.me.key".publicKeys = keysForSystem "aether";
  "cert/stu-dev.me.pem".publicKeys = keysForSystem "aether";

  "cert/stx.li.key".publicKeys = keysForSystem "aether";
  "cert/stx.li.pem".publicKeys = keysForSystem "aether";

  "mails/mail@stu-dev.me".publicKeys = keysForSystem "aether";
  "mails/csgo@stu-dev.me".publicKeys = keysForSystem "aether";
}

