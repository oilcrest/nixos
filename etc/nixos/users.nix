# This is my users file

{ config, pkgs, lib, ... }:
let 
  # Set the default username to nixuser
  user = "nixuser";
in 
{
  # User account
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    shell = pkgs.zsh;
    # This gives a default empty password
    passwordFile = "/persist/passwords/user";
    # initialHashedPassword = "";
    # Per user packages
    # packages = with pkgs; [ nix-prefetch-docker ];
  };
 
  # Automount Dropbox in /home/${user}/Dropbox
  fileSystems."/home/${user}/Dropbox" = {
  	device = "//192.168.122.1/Dropbox/Fedora";
  	fsType = "cifs";
  	options = [ "username=shareuser" "rw" "uid=1000" "gid=100" "x-systemd.automount" "noauto" ];
  };

  # doas rules
  security.doas.extraRules = [
  # { groups = [ "wheel" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--list" ]; }
  { users = [ "${user}" ]; keepEnv = true; persist = true; }
  { users = [ "${user}" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--list" ]; }
  { users = [ "${user}" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--update" ]; }
  { users = [ "${user}" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; args = [ "switch" ]; }
  { users = [ "${user}" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; args = [ "switch" "--upgrade" ]; }
  ];
}
