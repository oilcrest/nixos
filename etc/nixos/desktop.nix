# desktop.nix
{ config, lib, pkgs, ... }:

with lib;
{
  options = {  
    myDesktop = mkOption {
      type = types.str;
      default = "kde";
      description = "Desktop Environment to use";
    };
  };
  # config = desktopConfig.${myDesktop};
  config = mkMerge [
  (mkIf (config.myDesktop == "kde") { 
    services.xserver = {  
      enable = true;
      displayManager.sddm.enable = true;
      # displayManager.defaultSession = "plasmawayland";
      displayManager.defaultSession = "plasma";
      desktopManager.plasma5.enable = true;
      # X11 keymap
      layout = "gb";
    };
  })
  (mkIf (config.myDesktop == "pantheon") { 
    services.xserver = {
      enable = true;
      desktopManager.pantheon.enable = true;
      # X11 keymap
      layout = "gb";
    };
  })
  ];
}
