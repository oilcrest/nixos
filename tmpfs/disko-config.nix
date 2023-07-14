# tmpfs/disko-config.nix

{ disks ? [ "/dev/vda" ], ... }: {
  disko.devices = {
    disk = {
      vda = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              type = "partition";
              name = "ESP";
              start = "1M";
              end = "512M";
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "swap";
              type = "partition";
              start = "512M";
              end = "32G";
              part-type = "primary";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            }
            {
              name = "root";
              type = "partition";
              start = "32G";
              end = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/persist" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/machines" = {
                    mountpoint = "/var/lib/machines";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/portables" = {
                    mountpoint = "/var/lib/portables";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            }
          ];
        };
      };
    };
  };
}

