{ config, lib, pkgs, ... }:

let
  myDesktop = "pantheon";
  # Choose one of [ kde pantheon ]
  desktopConfig = {
    kde = {
      services.xserver = {  
        enable = true;
        displayManager.sddm.enable = true;
        # displayManager.defaultSession = "plasmawayland";
        displayManager.defaultSession = "plasma";
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
in
{
  config = desktopConfig.${myDesktop};
}

