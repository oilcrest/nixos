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
      mysshkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBHgdGf1R+oChwv0dWI9HjXyZwtLzoSdWJb3AlXK4bo agonzalez@tp01";
    };
  };
}
