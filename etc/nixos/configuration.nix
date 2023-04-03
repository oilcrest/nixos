# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  packageGroups = import ./packages.nix { inherit pkgs; };
  disko = builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz";
in
{
  imports =
    [
      ./hardware-configuration.nix
      "${disko}/module.nix"
      ./impermanence.nix
      ./users.nix
      ./vim.nix
      ./myparams.nix
    ];

  disko.devices = import ./disko-config.nix {
    disks = [ "/dev/vda" ]; 
  };

  nixpkgs.config = {
    allowUnfree = true;
    # packageOverrides = pkgs: {
    #  unstable = import <nixos-unstable> {
    #    config = config.nixpkgs.config;
    #  };
    # };
  };

  systemd.user.services.spice-agent = {
    enable = true;
    wantedBy = ["graphical-session.target"]; 
    serviceConfig = { ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x"; }; 
    unitConfig = { ConditionVirtualization = "vm"; 
      Description = "Spice guest session agent";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"]; 
    }; 
  }; 


  # https://nixos.wiki/wiki/Storage_optimization
  # nix.autoOptimiseStore = true;
  nix.settings.auto-optimise-store = true;
  # Garbage Collection 
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command
      extra-experimental-features = flakes
    '';
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  # Boot loader
  boot.loader = {
    efi.canTouchEfiVariables=true;
    # systemd-boot.enable = true;
    grub = { 
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
    };
    timeout = 3;
  };



  time.timeZone = "Europe/London";

  # Internationalisation
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };


  ################
  ##  Network  ###
  ################
  # networking.hostName = "nixos";
  networking.hostName = config.myParams.myhostname;
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];
  };


  #############
  ## Desktop ##
  #############

  # Enable X11, sddm and KDE plasma.
  services.xserver = {
	enable=true;
  	displayManager.sddm.enable = true;
    # displayManager.defaultSession = "plasmawayland";
  	desktopManager.plasma5.enable = true;
    # displayManager.setupCommands = "xrandr --output Virtual-1 --mode 1920x1064 --rate 59.97";
    displayManager.setupCommands = ''
      xrandr --output Virtual-1 --mode 1920x1080 --rate 60
      '';
    # X11 keymap
    layout = "gb";
  };


  #############
  ## Kernel ###
  #############

  # Custom Kernels
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_hardened;


  ################
  ### Drivers ####
  ################

  ### OpenGL ###
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  #   extraPackages = [ pkgs.libGL pkgs.libGLU ];
  # };


  ################
  ### Security ###
  ################

  services.packagekit.enable = true;
  services.fwupd.enable = true;

  # Enable Apparmor
  security.apparmor.enable = true;

  # Enable doas. Turn off sudo.
  security.doas.enable = true;
  security.sudo.enable = true;

  # Mount /tmp as tmpfs
  boot.tmpOnTmpfs = true;
  
  # Clean-out /var/tmp for files older than 7 days. 
  # systemd.tmpfiles.rules = [ "q /var/tmp 1777 root root 7d" ];
  # systemd.tmpfiles.rules = [ "d /var/tmp 1777 root root 7d" ];



  ################
  ### Programs ###
  ################

  # Set neovim as the default editor
  environment.variables.EDITOR = "nvim";

  programs.zsh.enable = true;

  environment.sessionVariables = rec {
    PATH = [ 
      "/persist/scripts"
    ];
  };

  # environment.shellAliases = {
  #   vim = "nvim";
  # };

  # programs.chromium = {
  #   enable = true;
  #   homepageLocation = "https://nixos.org"; 
  #   extensions =
  #   [
  #   "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
  #   "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
  #   ];	
  # };

  
  # System Packages to install
  environment.systemPackages = with packageGroups; my-package-set;

  # Install specific Nerd fonts 
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Hack" ]; })
  ];

  # Firejailed apps
  # programs.firejail = {
  #   enable = true;
  #   wrappedBinaries = 
  #   {     
  #     # librewolf
  #     jailwolf = {
  #       executable = "${lib.getBin pkgs.librewolf}/bin/librewolf";
  #       profile = "${pkgs.firejail}/etc/firejail/librewolf.profile";
  #       extraArgs = [ "--private=~/sandbox" ];
  #     };
  #     # firefox
  #     jailfox = {
  #       executable = "${lib.getBin pkgs.firefox}/bin/firefox --no-remote";
  #       profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
  #       extraArgs = [ "--private=~/sandbox" ];
  #     };
  #   };
  # };


  ############
  # Services #
  ############
 
  ### Sound ###
  # https://nixos.wiki/wiki/PipeWire
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  # Uncomment to use JACK applications:
  # jack.enable = true;
  };


  ### Flatpak ###
  services.flatpak.enable = true;
  # Daily updates wit systemd
  systemd.services.flatpak-update = {
    serviceConfig.Type = "oneshot";
    path = [ pkgs.flatpak ];
    serviceConfig.ExecStart = "${pkgs.flatpak}/bin/flatpak update -y";
  };
  systemd.timers.flatpak-update = {
    wantedBy = [ "timers.target" ];
    partOf = [ "flatpak-update.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 15:20:00";
      Unit = "flatpak-update.service";
    };
  };
  # XDG portals for sandboxed apps to work:
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.spice-vdagentd.enable = true;

  ### Podman ###
  virtualisation = {
    podman = {
      enable = true;
      # docker alias for podman
      dockerCompat = true;
    };
  };

  ### SSH ###
  services.openssh = {
   enable = true;
   passwordAuthentication = false;
   allowSFTP = false; # Don't set this if you need sftp
   kbdInteractiveAuthentication = false;
   extraConfig = ''
     AllowTcpForwarding yes
     X11Forwarding no
     AllowAgentForwarding no
     AllowStreamLocalForwarding no
     AuthenticationMethods publickey
   '';
  };


  system.copySystemConfiguration = true;

  # Read the doc before updating
  system.stateVersion = "22.11";

}

