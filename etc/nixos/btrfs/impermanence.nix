# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  myuser = config.myParams.myusername;
in
{
  imports = [ "${impermanence}/nixos.nix" ];

    users.users.${myuser} = {
      passwordFile = "/persist/passwords/user";
    };

  # filesystem modifications needed for impermanence
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;

  # reset / at each boot
  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt

    # Mount the btrfs root to /mnt
    mount -o subvol=@ /dev/vda3 /mnt

    # Delete the root subvolume
    echo "deleting root subvolume..." &&
    btrfs subvolume delete /mnt/root

    # Restore new root from root-blank
    echo "restoring blank @root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    # Unmount /mnt and continue boot process
    umount /mnt
  '';

  # configure impermanence
  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
      "/etc/ssh"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  environment.sessionVariables = rec {
    PATH = [ 
      "/persist/scripts"
    ];
  };

}

