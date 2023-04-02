# Username,
# Password
# Hostname

{ config, lib, ... }:
with lib;
with types;
{
  options = {
    myParams = mkOption {
      type = attrs; # Should probably be `submodule?
      description = "My config attrs";
    };
  };
  config = {
    myParams = {
      myusername = "nixuser";
      myhostname = "nixos";
      mysshkey = "";
    };
  };
}
