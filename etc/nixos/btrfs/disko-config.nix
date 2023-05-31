# btrfs/disko-config.nix

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
              name = "ESP";
              start = "1MiB";
              end = "1G";
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
              start = "1G";
              end = "9G";
              part-type = "primary";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            }
            {
              name = "root";
              start = "9G";
              end = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "@" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  # Mountpoints inferred from subvolume name
                  "@/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "@/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  # To avoid errors when deleting root subvolume, need
                  # to have /srv and /tmp either as subvolumes or dirs
                  # "/@/srv" = {
                  #   mountpoint = "/srv";
                  #   mountOptions = [ "compress=zstd" "noatime" ];
                  # };
                  # "/@/tmp" = {
                  #   mountpoint = "/tmp";
                  #   mountOptions = [ "compress=zstd" "noatime" ];
                  # };
                  "@/machines" = {
                    mountpoint = "/var/lib/machines";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@/portables" = {
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

