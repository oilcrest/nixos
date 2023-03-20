# This is my users file

{ config, pkgs, lib, ... }:
let 
  me = "k";
in 
{
  # User account
  users.users.${me} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    shell = pkgs.zsh;
    # This gives a default empty password
    passwordFile = "/persist/passwords/user";
    # initialHashedPassword = "";
    # Per user packages
    # packages = with pkgs; [ nix-prefetch-docker ];
  };
 
  # Automount Dropbox in /home/${me}/Dropbox
  fileSystems."/home/${me}/Dropbox" = {
  	device = "//192.168.122.1/Dropbox/Fedora";
  	fsType = "cifs";
  	options = [ "username=shareuser" "rw" "uid=1000" "gid=100" "x-systemd.automount" "noauto" ];
  };

  # doas rules
  security.doas.extraRules = [
  # { groups = [ "wheel" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--list" ]; }
  { users = [ "${me}" ]; keepEnv = true; persist = true; }
  { users = [ "${me}" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--list" ]; }
  { users = [ "${me}" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--update" ]; }
  { users = [ "${me}" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; args = [ "switch" ]; }
  { users = [ "${me}" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; args = [ "switch" "--upgrade" ]; }
  ];
}
