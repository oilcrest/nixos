{ config, lib, pkgs, ... }:

let
  # One of [ kde pantheon ]
  myDesktop = "kde";
  desktopConfigs = {
    kde = {
      services.xserver = {  
        enable = true;
        displayManager.sddm.enable = true;
        displayManager.defaultSession = "plasmawayland";
        desktopManager.plasma5.enable = true;
        # X11 keymap
        layout = "gb";
      };
    };
    pantheon = {
      services.xserver = {
        enable = true;
        desktopManager.pantheon.enable = true;
        # X11 keymap
        layout = "gb";
      };
    };
  };
  desktopConfig = desktopConfigs.${myDesktop};
in
{
  config = desktopConfig;
}

