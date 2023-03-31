# This is my users file

{ config, pkgs, lib, ... }:
let 
  # Read params file for username
  myuser = config.myParams.myusername;
  mysshkey = config.myParams.mysshkey;
in 
{
  # User account
  users.users.${myuser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    shell = pkgs.zsh;
    # This gives a default empty password
    initialHashedPassword = "";
    # passwordFile = "/persist/passwords/user";
    openssh.authorizedKeys.keys = [ "${mysshkey}" ];
    # Per user packages
    # packages = with pkgs; [ nix-prefetch-docker ];
  };
 
  # Automount Dropbox in /home/${user}/Dropbox
  fileSystems."/home/${myuser}/Dropbox" = {
  	device = "//192.168.122.1/Dropbox/Fedora";
  	fsType = "cifs";
  	options = [ "username=shareuser" "rw" "uid=1000" "gid=100" "x-systemd.automount" "noauto" ];
  };

  # doas rules
  security.doas.extraRules = [
  # { groups = [ "wheel" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--list" ]; }
  { users = [ "${myuser}" ]; keepEnv = true; persist = true; }
  { users = [ "${myuser}" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--list" ]; }
  { users = [ "${myuser}" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--update" ]; }
  { users = [ "${myuser}" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; args = [ "switch" ]; }
  { users = [ "${myuser}" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; args = [ "switch" "--upgrade" ]; }
  ];
}
