# myparams.nix

{ config, lib, ... }:
with lib;
{
  options = {
    myParams = mkOption {
      type = types.attrs; # Should probably be `submodule?
      description = "My config attrs";
    };
  };
  config = {
    myParams = {
      myusername = "nixuser";
      myhostname = "nixos";
      mysshkey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBDj2FdHqTEFS2AFwVXbc/93v+tKlD5MlSOFwWlGAJoNVFuOZh0sptdnaDR1XwIFCfGtFGvx0vNHJxe8uIFUbP0= (none)";
      mydesktop = "kde";
    };
  };
}
