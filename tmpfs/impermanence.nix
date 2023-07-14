# tmpfs/impermanence.nix

{ config, impermanence, ... }:

let
  myuser = config.myParams.myusername;
in
{
  imports = [ impermanence.nixosModule ];

    users.users.${myuser} = {
      passwordFile = "/persist/passwords/user";
    };

  # Put root on tmpfs
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    # You must set mode=755. The default is 777, and OpenSSH will complain and disallow logins
    options = [ "relatime" "mode=755" ];
  };

  # filesystem modifications needed for impermanence
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;

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

  environment.sessionVariables = {
    PATH = [ 
      "/persist/scripts"
    ];
  };

}

