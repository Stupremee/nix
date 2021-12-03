{ ... }:
{
  users.users.root = {
    hashedPassword = "$6$kXVCr27G60l.a7z9$4iRje1ZUDkEgrxNXwV6gF5cLoIheXNflPwNwQssLufYESkrH1s2wW0nWtC.y2rVtdmRusCHP2GIgKS/7DQ6cG0";
    openssh.authorizedKeys.keyFiles = [ ../../secrets/keys/yubikey.pub ];
  };
}
