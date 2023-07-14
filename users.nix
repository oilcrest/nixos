# users.nix

{ config, pkgs, ... }:
let 
  # Read params file for username
  myuser = config.myParams.myusername;
  mysshkey = config.myParams.mysshkey;
in 
{
  # User account
  users.users.${myuser} = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    # This gives a default empty password
    initialHashedPassword = "";
    openssh.authorizedKeys.keys = [ "${mysshkey}" ];
  };
 
  # doas rules
  security.doas.extraRules = [
    # { groups = [ "wheel" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--list" ]; }
    { users = [ "${myuser}" ]; keepEnv = true; persist = true; }
    { users = [ "${myuser}" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; args = [ "boot" "--flake" "/etc/nixos" ]; }
    { users = [ "${myuser}" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; args = [ "switch" "--flake" "/etc/nixos" ]; }
    { users = [ "${myuser}" ]; keepEnv = true; noPass = true; cmd = "reboot"; }
  ];
}
