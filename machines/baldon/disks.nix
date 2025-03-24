{ ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/49c8985c-4b48-4bd3-999b-13d8867e11c9";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/E840-B125";
      fsType = "vfat";
    };
  };

  boot.initrd.luks.devices."cryptroot".device =
    "/dev/disk/by-uuid/fd2c2d53-f858-4642-9127-593e78f2dbcf";

  swapDevices = [
    { device = "/dev/disk/by-uuid/fbe5f07a-5bcc-41a4-b492-596f98247466"; }
  ];

}
