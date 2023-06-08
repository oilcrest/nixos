# desktop.nix
{ config, lib, pkgs, ... }:

# Current desktops supported:
# kde pantheon
# Set desktop in configuration.nix
with lib;
{
  options = {  
    myDesktop = mkOption {
      type = types.str;
      default = "kde";
      description = "Desktop Environment to use";
    };
  };
  config = mkMerge [
  (mkIf (config.myDesktop == "kde") { 
    services.xserver = {  
      enable = true;
      displayManager.sddm.enable = true;
      # displayManager.defaultSession = "plasmawayland";
      displayManager.defaultSession = "plasma";
      desktopManager.plasma5.enable = true;
    };
  })
  (mkIf (config.myDesktop == "pantheon") { 
    services.xserver = {
      enable = true;
      desktopManager.pantheon = {
        enable = true;
        extraGSettingsOverrides = ''
        [io.elementary.terminal.settings] 
        font='Hack Nerd Font Mono 10'
        follow-last-tab=true
        '';
        extraGSettingsOverridePackages = [
          pkgs.pantheon.elementary-terminal 
        ];
      };
    };
    programs.pantheon-tweaks.enable = true;
  })
  # Common desktop config settings go below
  ({
    # X11 keymap
    services.xserver.layout = "gb";
  })
  ];
}
