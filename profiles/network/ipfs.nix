{ config, ... }: {
  services.ipfs = {
    enable = true;
    user = "stu";
  };
}
